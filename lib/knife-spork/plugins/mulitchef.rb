require "knife-spork/plugins/plugin"

module KnifeSpork
  module Plugins
    class MultiChef < Plugin
      name :multichef

      def after_upload
        puts config
      end
    end
  end
end
