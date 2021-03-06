require 'chef/knife'

module KnifeSpork
  class SporkEnvironmentFromFile < Chef::Knife

    deps do
      require 'knife-spork/runner'
      require 'json'
      require 'chef/knife/environment_from_file'
    end

    banner 'knife spork environment from file FILENAME (options)'
    
    option :message,
           :short => '-m',
           :long => '--message git_message',
           :description => 'Git commit message if auto_push is enabled'

    def run
      self.class.send(:include, KnifeSpork::Runner)
      self.config = Chef::Config.merge!(config)

      if @name_args.empty?
        show_usage
        ui.error("You must specify a environment name")
        exit 1
      end

      @name_args.each do |arg|
        @object_name = arg.split("/").last
        run_plugins(:before_environmentfromfile)
        begin
          pre_environment = load_environment(@object_name.gsub(".json","").gsub(".rb",""))
        rescue Net::HTTPServerException => e
          pre_environment = {}
        end
        environment_from_file
        post_environment = load_environment(@object_name.gsub(".json","").gsub(".rb",""))
        @object_difference = json_diff(pre_environment,post_environment).to_s
        @environments = [ post_environment ]
        @args = { :git_message => config[:message] } 
        run_plugins(:after_environmentfromfile)
      end
    end

    private
    def environment_from_file
      rff = Chef::Knife::EnvironmentFromFile.new
      rff.name_args = @name_args
      rff.run
    end
  end
end
