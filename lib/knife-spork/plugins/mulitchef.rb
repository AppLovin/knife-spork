require "knife-spork/plugins/plugin"

module KnifeSpork
  module Plugins
    class MultiChef < Plugin
      name :multichef

      def perform end;

      def after_upload
        puts "hello"
        puts config
      end
    end
  end
end
