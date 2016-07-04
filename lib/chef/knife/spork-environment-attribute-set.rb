require 'chef/knife'
require 'knife-spork/runner'
require 'knife-spork/utils'
require 'set'
require 'json'

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

    option :remarks,
           :long => '--remarks',
           :description => 'append to git commit message'

    option :no_upload,
           :long => '--no_upload',
           :description => 'whether or not to upload environment file'

    option :branch,
           :long => '--branch BRANCH',
           :description => 'name of the branch to fork'

    option :commit_message,
           :long => '--commit_message MSG',
           :description => 'commit message'

    def run 
      self.config = Chef::Config.merge!(config)

      if @name_args.empty? 
        show_usage
        ui.error("You must specify a environment name, attribute and value")
        exit 1
      end

      group = @name_args.first

      environments = @name_args[0].split(",").map { |env| load_specified_environment_group(env) }.flatten

      if environments.length == 0
        ui.error("Environment group #{group} not found.")
        exit 2
      end

      value = begin
                JSON.load(@name_args[2].to_s)
              rescue JSON::ParserError
                JSON.load("\"#{@name_args[2]}\"")
              end

      @args = { 
        :environments => [],
        :attribute => @name_args[1], 
        :value => value, 
        :remarks => config[:remarks],
        :branch => config[:branch],
        :commit_message => config[:commit_message]
        } 

      run_plugins(:before_environment_attribute_set)
     
      environments.each do |env|
        environment = load_environment_from_file(env)
      
        create_if_missing = if config[:create_if_missing].nil?
                              false
                            else
                              true
                            end


        ui.msg "Modifying #{env}"
        modified = override_attribute(@name_args[1], value, environment, create_if_missing = create_if_missing )

        if modified 
          new_environment_json = pretty_print_json(environment.to_hash)
          save_environment_changes(env, new_environment_json)

          if config[:no_upload].nil?
            environment.save
          end

          ui.msg "Done modifying #{env} at #{Time.now}"
          @args[:environments] << env
        else
            ui.msg "Environment #{env} not modified."
        end 
      end

      run_plugins(:after_environment_attribute_set)
    end
  
    def override_attribute(attribute, value, environment, create_if_missing = false)
        old_hash = environment.override_attributes.hash
        environment.override_attributes = Utils.hash_set(attribute, value, environment.override_attributes, 
          create_if_missing = create_if_missing)

        old_hash != environment.override_attributes.hash
    end
  end
end
