require 'knife-spork/utils'

module KnifeSpork
  describe Utils do
    describe "hash_unset_recursive" do
      environment = {
        "object1" => {
          "object2" => {
          "attribute" => 1
          },
          "my_list" => [
            "hello", 
            "world"
          ],
          "object4" => {
            "quoted.attribute" => "1"
          }
        },
        "object" => 2,
        "object4" => "some_string value",
        "my_list" => "1,2",
      }

      it "unsets object1.object2.attribute" do
        expect(environment['object1']['object2'].has_key? "attribute").to eq(true)
        environment = Utils.hash_unset("object1.object2.attribute", environment)  
        expect(environment['object1']['object2'].has_key? "attribute").to eq(false)
      end

      it "preserves original hash if non existent attribute is unset" do
        updated_environment = Utils.hash_unset("object1.object3", environment)  
        expect(updated_environment).to eq(environment)
      end

      it "unsets single level attribute" do
        expect(environment.has_key? "my_list").to eq(true)
        environment = Utils.hash_unset("my_list", environment)  
        expect(environment.has_key? "my_list").to eq(false)
      end

      it 'unsets object1.object3."quoted.attribute"' do
        expect(environment['object1']['object4'].has_key? "quoted.attribute").to eq(true)
        environment = Utils.hash_unset("object1.object4.\"quoted.attribute\"", environment)  
        expect(environment['object1']['object4'].has_key? "quoted.attribute").to eq(false)
      end
    end
  end
end
