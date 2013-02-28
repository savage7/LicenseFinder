module LicenseFinder
  class SourceSyncer
    def initialize(source_dependencies, dependencies)
      @source_dependencies = Array source_dependencies
      @dependencies = dependencies
    end

    def sync!
      destroy_obsolete_dependencies
      update_existing_dependencies
      create_new_dependencies
      dependencies
    end

    protected
    attr_accessor :dependencies, :source_dependencies

    def destroy_obsolete_dependencies
      obsolete_dependencies = dependencies.select {|d| !source_dependencies.detect {|s| s.name == d.name }}
      obsolete_dependencies.map &:destroy

      self.dependencies -= obsolete_dependencies
    end

    def update_existing_dependencies
      dependencies.each do |d|
        source_dep = source_dependencies.detect { |s| s.name == d.name }
        d.merge(source_dep) unless d.instance_variable_get("@manual")
        self.source_dependencies -= [source_dep]
      end
    end

    def create_new_dependencies
      source_dependencies.each do |d|
        dependencies << d
        d.save
      end
    end
  end
end
