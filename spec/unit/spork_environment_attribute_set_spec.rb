require 'app_conf'
require 'chef/knife/spork-environment-attribute-set'

module KnifeSpork
  describe SporkEnvironmentAttributeSet do
    let(:spork_config) do
      AppConf.new().tap do |conf|
        allow(conf).to receive(:environment_groups).and_return({ "test" => [ "TestEnvironment1", "TestEnvironment2" ] })
      end
    end

    let(:test_environment1) do
      double().tap do |d|
        allow(d).to receive(:to_hash)
      end
    end

    let(:test_environment2) do
      double().tap do |d|
        allow(d).to receive(:to_hash)
      end
    end

    describe "#run" do
      it "does not upload environment if --no_upload is passed" do
        knife = SporkEnvironmentAttributeSet.new([ "test", "hello", "world" ]).tap do |k|
          allow(k).to receive(:spork_config).and_return(spork_config)
          allow(k).to receive(:run_plugins)
          allow(k.ui).to receive(:msg)
          allow(k).to receive(:override_attribute).and_return(true)
          allow(k).to receive(:pretty_print_json)
          allow(k).to receive(:save_environment_changes)
          allow(k).to receive(:load_environment_from_file).with("TestEnvironment1").and_return(test_environment1)
          allow(k).to receive(:load_environment_from_file).with("TestEnvironment2").and_return(test_environment2)
          allow(k).to receive(:config).and_return({ :create_if_missing => true , :no_upload => true })
        end


        expect(test_environment1).not_to receive(:save)
        expect(test_environment2).not_to receive(:save)

        knife.run
      end

      it "accepts hash as value" do
        knife = SporkEnvironmentAttributeSet.new([ "test", "json", '{ "hello": "world" }' ]).tap do |k|
          allow(k).to receive(:spork_config).and_return(spork_config)
          allow(k).to receive(:run_plugins)
          allow(k.ui).to receive(:msg)
          allow(k).to receive(:pretty_print_json)
          allow(k).to receive(:save_environment_changes)
          allow(k).to receive(:load_environment_from_file).with("TestEnvironment1").and_return(test_environment1)
          allow(k).to receive(:load_environment_from_file).with("TestEnvironment2").and_return(test_environment2)
          allow(k).to receive(:config).and_return({ :create_if_missing => true})
        end

        allow(test_environment1).to receive(:save)
        allow(test_environment2).to receive(:save)

        expect(knife).to receive(:override_attribute).with("json", {'hello' => 'world'}, test_environment1, true)
        expect(knife).to receive(:override_attribute).with("json", {'hello' => 'world'}, test_environment2, true)

        knife.run
      end
    end
  end
end
