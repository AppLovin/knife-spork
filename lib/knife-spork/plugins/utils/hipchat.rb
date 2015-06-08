module KnifeSpork
  module Plugins
    module Utils
      module HipchatUtils
        def self.prettify_attribute(attribute)
          attribute.gsub(/([^#]+)#/, "['\\1']").gsub(/(?<=\])([\w]+(\.[\w]+)*)/, "['\\1']" )
        end
      end
    end
  end
end
