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
          ]
        },
        "object" => 2,
        "object4" => "some_string value",
        "my_list" => "1,2"
      }

      it "unsets object1#object2#attribute" do
        expect(environment['object1']['object2'].has_key? "attribute").to eq(true)
        environment = Utils.hash_unset("object1#object2#attribute", environment)  
        expect(environment['object1']['object2'].has_key? "attribute").to eq(false)
      end

      it "preserves original hash if non existent attribute is unset" do
        updated_environment = Utils.hash_unset("object1#object3", environment)  
        expect(updated_environment).to eq(environment)
      end

      it "unsets single level attribute" do
        expect(environment.has_key? "my_list").to eq(true)
        environment = Utils.hash_unset("my_list", environment)  
        expect(environment.has_key? "my_list").to eq(false)
      end
    end


    describe "hash_set" do
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
        "object4" => "some_string value",
        "my_list" => "1,2"
      }

      it "changes value of first level attribute" do 
        expect(environment["object3"]).to eq(nil)
        environment = Utils.hash_set("object3", 1, environment) 
        expect(environment["object3"]).to eq(1)
      end

      it "changes value of nested attribute" do 
        environment = Utils.hash_set("object1#object2#attribute", 2, environment)
        expect(environment["object1"]["object2"]["attribute"]).to eq(2)
      end

      it "changes value of nonexistent nested attribute" do 
        environment = Utils.hash_set("object1#object3#attribute", 2, environment, create_if_missing=true)
        expect(environment["object1"]["object3"]["attribute"]).to eq(2)
      end

      it "changes value of existing attribute when new attribute has more nesting" do 
        environment = Utils.hash_set("object4#object5#attribute", 2, environment, create_if_missing=true)
        expect(environment["object4"]["object5"]["attribute"]).to eq(2)
      end

      it "changes value of attribute that . delimited" do
        environment = Utils.hash_set("object1#object2#attribute.something", 2, environment, create_if_missing=true)
        expect(environment["object1"]["object2"]["attribute.something"]).to eq(2)
      end

      it "changes value of first level attribute that is . delimited" do
        environment = Utils.hash_set("object1#attribute.something", 2, environment, create_if_missing=true)
        expect(environment["object1"]["attribute.something"]).to eq(2)
      end

      it "creates a list" do 
        some_list = "the quick brown fox".split(" ")
        environment = Utils.hash_set("object1#some.list", some_list, environment, create_if_missing=true, append=true)
        expect(environment["object1"]["some.list"]).to eq(some_list)
      end

      it "appends to a list" do
        some_list = "brown fox".split(" ")
        environment = Utils.hash_set("object1#my_list", some_list, environment, create_if_missing=true, append=true)
        expect(environment["object1"]["my_list"]).to eq(["hello", "world"] + some_list)
      end

      it "changes list to string" do
        environment = Utils.hash_set("object1#my_list", "hello world", environment)
        expect(environment["object1"]["my_list"]).to eq("hello world")
      end

      it "changes string to a list" do
        environment = Utils.hash_set("my_list", "hello,world".split(","), environment, create_if_missing=false, append=true)
        expect(environment["my_list"]).to eq(["hello", "world"])
      end
    end
  end
end
