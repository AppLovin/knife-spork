require 'chef/knife/spork-environment-attribute-unset'
require 'app_conf'

module KnifeSpork
  describe SporkEnvironmentAttributeUnset do
    let(:spork_config) do
      AppConf.new().tap do |conf|
        allow(conf).to receive(:environment_groups).and_return({ "test" => [ "TestEnvironment1", "TestEnvironment2" ] })
      end
    end

    subject(:knife) do
      SporkEnvironmentAttributeUnset.new(['test', 'hello']).tap do |k|
        allow(k).to receive(:run_plugins)
        allow(k.ui).to receive(:msg)
        allow(k).to receive(:unset_attribute).and_return(true)
        allow(k).to receive(:pretty_print_json)
        allow(k).to receive(:save_environment_changes)
        allow(k).to receive(:spork_config).and_return(spork_config)
        allow(k).to receive(:load_environment_from_file).with("TestEnvironment1").and_return(test_environment1)
        allow(k).to receive(:load_environment_from_file).with("TestEnvironment2").and_return(test_environment2)
      end
    end

    let(:test_environment1) do
      double()
    end

    let(:test_environment2) do
      double()
    end

    context '#run' do
      it 'accepts a group of environments' do
        expect(test_environment1).to receive(:to_hash)
        expect(test_environment1).to receive(:save)

        expect(test_environment2).to receive(:to_hash)
        expect(test_environment2).to receive(:save)

        knife.run
      end

      it 'accepts a list of environments' do
        k = SporkEnvironmentAttributeUnset.new(['TestEnvironment1,TestEnvironment2', 'hello']).tap do |k|
          allow(k).to receive(:run_plugins)
          allow(k.ui).to receive(:msg)
          allow(k).to receive(:unset_attribute).and_return(true)
          allow(k).to receive(:pretty_print_json)
          allow(k).to receive(:save_environment_changes)
          allow(k).to receive(:spork_config).and_return(spork_config)
          allow(k).to receive(:load_environment_from_file).with("TestEnvironment1").and_return(test_environment1)
          allow(k).to receive(:load_environment_from_file).with("TestEnvironment2").and_return(test_environment2)
        end

        expect(test_environment1).to receive(:to_hash)
        expect(test_environment1).to receive(:save)

        expect(test_environment2).to receive(:to_hash)
        expect(test_environment2).to receive(:save)

        k.run
      end
    end
  end
end
