require 'knife-spork/plugins/utils/hipchat'

module KnifeSpork
  module Plugins
    module Utils
      describe "Hipchat utils" do
        describe "prettify attribute" do
          it "prettifies environment set attribute attribute param" do 
            expect(HipchatUtils.prettify_attribute("object1#object2#some.attribute")).to eq("['object1']['object2']['some.attribute']")
          end 

          it "accounts for _" do 
            expect(HipchatUtils.prettify_attribute("object_name#some.attribute")).to eq("['object_name']['some.attribute']")
          end
          
          it "accounts for ." do 
            expect(HipchatUtils.prettify_attribute("object.name#some.attribute")).to eq("['object.name']['some.attribute']")
          end
        end
      end
    end
  end
end
