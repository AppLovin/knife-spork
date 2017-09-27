require "knife-spork/plugins/plugin"
require "chef/server_api"
require "chef/cookbook_uploader"

module KnifeSpork
  module Plugins
    class MultiChef < Plugin
      name :multichef

      def perform; end

      def after_upload
        cookbooks.each do |cookbook|
          chef_servers.each do |chef_server|
            uploader = Chef::CookbookUploader.new(cookbook, :rest => chef_server)
            cookbook.freeze_version
            ui.info "Uploading #{cookbook.name} at #{cookbook.version} to #{chef_server.url}"
            uploader.upload_cookbooks
            ui.info "Upload to #{chef_server.url} successful!"
          end
        end
      end

      def after_promote_remote
        environments.each do |environment|
          chef_servers.each do |chef_server|
            environment.chef_server_rest = Chef::ServerAPI.new(chef_server.url)
            ui.info "Uploading #{environment.name}.json to Chef Server"
            environment.save
            ui.info "Promotion complete at #{Time.now}!"
          end
        end
      end

      def chef_servers
        raise "No mirror Chef server(s) specified in multichef config" if config.servers.nil? or config.servers.length == 0
        @chef_servers ||= config.servers.map { |uri| Chef::ServerAPI.new(uri) }
      end
    end
  end
end
