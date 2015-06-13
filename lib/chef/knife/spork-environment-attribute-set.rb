require 'chef/knife'
require 'knife-spork/runner'
require 'knife-spork/utils'

module KnifeSpork
  class SporkEnvironmentAttributeSet < Chef::Knife

    banner 'knife spork environment attribute set ENVIRONMENT ATTRIBUTE VALUE'

    include KnifeSpork::Runner
    include Utils

    option :create_if_missing,
           :long => '--create_if_missing',
           :description => 'Create attribute if missing'

    option :force_string,
           :long => '--force_string',
           :description => 'Force value to a string'

    def run 
      self.config = Chef::Config.merge!(config)

      if @name_args.empty? 
        show_usage
        ui.error("You must specify a environment name, attribute and value")
        exit 1
      end

      group = @name_args.first

      if spork_config.environment_groups[group].nil?
        ui.error("Environment group #{group} not found.")
      end

      run_plugins(:before_environment_attribute_set)
      
      @args = { 
        :environments => spork_config.environment_groups[group],
        :attribute => @name_args[1], 
        :value => @name_args[2] } 

      spork_config.environment_groups[group].each do |env|
        environment = load_environment_from_file(env)

        ui.msg "Modifying #{env}"
        override_attribute(@name_args[1], value, environment, create_if_missing = create_if_missing)

        new_environment_json = pretty_print_json(environment.to_hash)
        save_environment_changes(env, new_environment_json)

        environment.save
        ui.msg "Done modifying #{env} at #{Time.now}"
      end

      run_plugins(:after_environment_attribute_set)
    end
  
    private
    def create_if_missing
      if config[:create_if_missing].nil?
        false
      else
        true
      end
    end

    def value
      value = @name_args[2]
      if config.has_key? :force_string
        value
      elsif value == "true"
        true
      elsif value =="false"
        false
      elsif value.is_a? Numeric
        value.to_i 
      else
        value
      end
    end

    def override_attribute(attribute, value, environment, create_if_missing = false)
      environment.override_attributes = Utils.hash_set_recursive(attribute, value,
        environment.override_attributes, create_if_missing)
    end
  end
end
