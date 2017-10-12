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
            slack "#{organization}#{current_user} uploaded the following cookbooks:\n#{cookbooks.collect{ |c| "  #{c.name}@#{c.version}" }.join("\n")} to mirror #{chef_server.url}"
          end
        end
      end

      def after_promote_remote
        environments.each do |environment|
          chef_servers.each do |chef_server|
            environment.chef_server_rest = Chef::ServerAPI.new(chef_server.url)
            ui.info "Uploading #{environment.name}.json to #{chef_server.url}"
            environment.save
            ui.info "Promotion complete at #{Time.now}!"
            slack "#{organization}#{current_user} promoted the following cookbooks:\n#{cookbooks.collect{ |c| "  #{c.name}@#{c.version}" }.join("\n")} to #{environments.collect{ |e| "#{e.name}" }.join(", ")} to mirror #{chef_server.url}"
          end
        end
      end

      def after_environmentfromfile
        environments.each do |environment|
          chef_servers.each do |chef_server|
            environment.chef_server_rest = Chef::ServerAPI.new(chef_server.url)
            ui.info "Uploading #{environment.name}.json to #{chef_server.url}"
            environment.save
            ui.info "Promotion complete at #{Time.now}!"
            slack "#{organization}#{current_user} #{environment.name}.json to mirror #{chef_server.url}"
          end
        end
      end

      def after_nodeedit
        nodes.each do |node|
          chef_servers.each do |chef_server|
            node.chef_server_rest = Chef::ServerAPI.new(chef_server.url)
            node.save
            ui.info "Updated node #{node.name} to #{chef_server.url}"
            slack "Updated node #{node.name} to #{chef_server.url}"
          end
        end
      end

      def after_rolefromfile
        roles.each do |role|
          chef_servers.each do |chef_server|
            role.chef_server_rest = Chef::ServerAPI.new(chef_server.url)
            role.save
            ui.info "Updated role #{role.name} to #{chef_server.url}"
            slack "Updated role #{role.name} to #{chef_server.url}"
          end
        end
      end

      def chef_servers
        raise "No mirror Chef server(s) specified in multichef config" if config.servers.nil? or config.servers.length == 0
        @chef_servers ||= config.servers.map { |uri| Chef::ServerAPI.new(uri) }
      end

      def slack(message)
        safe_require 'slack-notifier'
        slack_config = @options[:config].plugins.slack
        ui.error "No Slack Config" if slack_config.nil?
        @slack ||= begin
          notifier = ::Slack::Notifier.new( slack_config.webhook_url, channel: slack_config.channel, username: slack_config.username, icon_url: slack_config.icon_url)
          notifier.ping message
        rescue Exception => e
          ui.error 'Something went wrong sending to Slack.'
          ui.error e.to_s
        end
      end
    end
  end
end
