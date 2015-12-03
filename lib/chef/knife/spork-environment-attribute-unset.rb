require 'chef/knife'
require 'knife-spork/runner'
require 'knife-spork/utils'

module KnifeSpork
  class SporkEnvironmentAttributeUnset < Chef::Knife

    banner 'knife spork environment attribute unset ENVIRONMENT ATTRIBUTE'

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

      environments = if spork_config.environment_groups[group].nil?
        passed_envs = group.split(",")
        all_envs = spork_config.environment_groups.values.flatten
        if ! (all_envs & passed_envs).empty?
          passed_envs
        else
          ui.error("Environment group #{group} not found.")
        end
      else
        spork_config.environment_groups[group]
      end

      run_plugins(:before_environment_attribute_unset)
      
      @args = { 
        :environments => [],
        :attribute => @name_args[1], 
        :value => @name_args[2] } 

      environments.each do |env|
        environment = load_environment_from_file(env)

        ui.msg "Modifying #{env}"
        modified = unset_attribute(@name_args[1], environment)

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

      run_plugins(:after_environment_attribute_unset)
    end

    def unset_attribute(attribute, environment)
        old_hash = environment.override_attributes.hash
        environment.override_attributes = Utils.hash_unset(attribute, environment.override_attributes) 

        old_hash != environment.override_attributes.hash
    end
  end
end
