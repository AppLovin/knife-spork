require 'knife-spork/utils'

module KnifeSpork
  describe Utils do
    describe "hash_set_recursive" do
      environment = {
        "object1" => {
          "object2" => {
          "attribute" => 1
          },
          "my_list" => [
            "hello", 
            "world"
          ]
        },
        "object" => 2,
        "object4" => "some_string value"
      }

      it "changes value of first level attribute" do 
        environment = Utils.hash_set_recursive("object3", 1, environment) 
        expect(environment["object3"]).to eq(1)
      end

      it "changes value of nested attribute" do 
        environment = Utils.hash_set_recursive("object1#object2#attribute", 2, environment)
        expect(environment["object1"]["object2"]["attribute"]).to eq(2)
      end

      it "changes value of nonexistent nested attribute" do 
        environment = Utils.hash_set_recursive("object1#object3#attribute", 2, environment, create_if_missing=true)
        expect(environment["object1"]["object3"]["attribute"]).to eq(2)
      end

      it "changes string value of existing nested attribute when create_if_missing=true" do 
        environment = Utils.hash_set_recursive("object4#object5#attribute", 2, environment, create_if_missing=true)
        expect(environment["object4"]["object5"]["attribute"]).to eq(2)
      end

      it "does not change value of non-existent nested attribute by default" do 
        environment = Utils.hash_set_recursive("object4#object5#attribute", 2, environment)
        expect(environment["object4"]["object6"].nil?).to eq(true)
      end

      it "changes value of attribute that is # delimited" do 
        environment = Utils.hash_set_recursive("object1#object2#attribute.something", 2, environment)
        expect(environment["object1"]["object2"]["attribute.something"]).to eq(2)
      end

      it "changes value of first level attribute that is # delimited" do 
        environment = Utils.hash_set_recursive("object1#attribute.something", 2, environment)
        expect(environment["object1"]["attribute.something"]).to eq(2)
      end

      it "creates a list" do 
        some_list = "the quick brown fox".split(" ")
        environment = Utils.hash_set_recursive("object1#some.list", some_list, environment, create_if_missing=true, array=true)
        expect(environment["object1"]["some.list"]).to eq(some_list)
      end

      it "appends to a list" do
        some_list = "brown fox".split(" ")
        environment = Utils.hash_set_recursive("object1#my_list", some_list, environment, create_if_missing=true, array=true)
        expect(environment["object1"]["my_list"]).to eq(["hello", "world"] + some_list)
      end
    end
  end
end
