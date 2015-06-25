require 'chef/knife'
require 'knife-spork/runner'
require 'knife-spork/utils'

module KnifeSpork
  class SporkEnvgroupAttributeSet < Chef::Knife

    banner 'knife spork envgroup attribute set ENVIRONMENT ATTRIBUTE VALUE'

    include KnifeSpork::Runner
    include Utils

    option :create_if_missing,
           :long => '--create_if_missing',
           :description => 'Create attribute if missing'

    option :force_string,
           :long => '--force_string',
           :description => 'Force value to a string'

    option :append,
           :long => '--append',
           :description => 'treat value as an array'

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

      run_plugins(:before_envgroup_attribute_set)
      
      @args = { 
        :environments => [],
        :attribute => @name_args[1], 
        :value => @name_args[2] } 

      spork_config.environment_groups[group].each do |env|
        environment = load_environment_from_file(env)

        create_if_missing = if config[:create_if_missing].nil?
                              false
                            else
                              true
                            end


        ui.msg "Modifying #{env}"
        modified = override_attribute(@name_args[1], value, environment, create_if_missing = create_if_missing, append = append? )

        if modified 
          new_environment_json = pretty_print_json(environment.to_hash)
          save_environment_changes(env, new_environment_json)

          environment.save
          ui.msg "Done modifying #{env} at #{Time.now}"
          @args[:environments] << env
        else
            ui.msg "Environment #{env} not modified."
        end 
      end

      run_plugins(:after_envgroup_attribute_set)
    end

    def append?
      is_array = if config.has_key? :append
        begin 
          @name_args[2].split(",")
        rescue NoMethodError
          ui.error("#{value} is not array of values. HINT: Place commas delimiting each value")
          exit 1
        end
        true
      else 
        false
      end
    end
  
    def value
      value = @name_args[2]
      if config.has_key? :force_string
        value
      elsif append? | /(.+,){1,}/.match(value)
        value.split(",")
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

    def override_attribute(attribute, value, environment, create_if_missing = false, append = false)
        old_hash = environment.override_attributes.hash
        environment.override_attributes = Utils.hash_set_recursive(attribute, value, environment.override_attributes, 
          create_if_missing = create_if_missing, append = append)

        old_hash != environment.override_attributes.hash
    end
  end
end
