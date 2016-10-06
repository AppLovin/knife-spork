require 'chef/knife'
require 'knife-spork/runner'
require 'knife-spork/utils'
require 'set'
require 'json'
require 'chef/mixin/deep_merge'

module KnifeSpork
  class SporkEnvironmentAttributeSet < Chef::Knife

    banner 'knife spork environment attribute set ENVIRONMENT ATTRIBUTE VALUE'

    include KnifeSpork::Runner

    option :no_upload,
           :long => '--no_upload',
           :description => 'whether or not to upload environment file'

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
        old_override_attributes = environment.override_attributes
        environment.override_attributes = merge(environment.override_attributes, hashify(@name_args[1], value))

        if old_override_attributes != environment.override_attributes
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

    def hashify(string, value)
      {}.tap do |h|
        keys = string.split(':')
        keys.reduce(h){ |h,j| h[j] = (j == keys.last ? value : {}) }
      end
    end

    def merge(i, j)
      Chef::Mixin::DeepMerge.merge(i,j)
    end
  end
end
