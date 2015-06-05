require 'knife-spork/utils'

module KnifeSpork
  describe Utils do
    describe "walk_and_replace" do

      it "changes value of first level attribute" do 
        json = {
          :object1 => {
            :object2 => {
              :attribute => 1
            }
          },
          "object3" => 2
        }

        json = Utils.hash_set_recursive("object3", 1, json) 
        expect(json["object3"]).to eq(1)
      end

      it "changes value of nested attribute" do 
        json = {
          "object1" => {
            "object2" => {
              "attribute" => 1
            }
          }
        }

        json = Utils.hash_set_recursive("object1.object2.attribute", 2, json)
        expect(json["object1"]["object2"]["attribute"]).to eq(2)
      end
    end
  end
end
