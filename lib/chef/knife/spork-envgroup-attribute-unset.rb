require 'chef/knife'
require 'knife-spork/runner'
require 'knife-spork/utils'

module KnifeSpork
  class SporkEnvgroupAttributeUnset < Chef::Knife

    banner 'knife spork envgroup attribute unset ENVIRONMENT ATTRIBUTE'

    include KnifeSpork::Runner
    include Utils

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

        ui.msg "Modifying #{env}"
        modified = unset_attribute(@name_args[1], environment, create_if_missing)

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

    def unset_attribute(attribute, environment)
        old_hash = environment.override_attributes.hash
        environment.override_attributes = Utils.hash_unset(attribute, environment.override_attributes) 

        old_hash != environment.override_attributes.hash
    end
  end
end
