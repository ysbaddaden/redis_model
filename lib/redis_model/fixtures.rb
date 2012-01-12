class Test::Unit::TestCase
  def self.fixtures_path
  end

  def self.load_fixtures
    Dir[File.expand_path('*.yml', fixtures_path)].each do |file_name|
      base_name  = File.basename(file_name).sub(/\.yml$/i, "")
      class_name = base_name.singularize.camelize.constantize
      
      class_eval <<-EOV
        def self.#{base_name}(name = nil)
          @#{base_name} ||= {}
          if name
            @#{base_name}[name.to_sym]
          else
            @#{base_name}
          end
        end
        
        def #{base_name}(name = nil)
          self.class.#{base_name}(name)
        end
      EOV
      
      yaml = YAML.load_file(file_name)
      yaml.each { |name, attributes|
        send(base_name)[name.to_sym] = class_name.create(attributes)
      } if yaml
    end
  end
end
