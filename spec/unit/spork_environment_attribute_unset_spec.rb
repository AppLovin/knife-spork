require 'chef/knife/spork-environment-attribute-unset'

module KnifeSpork
  describe SporkEnvironmentAttributeUnset do
    let(:env_args) { nil }
    let(:test_environment1) { double() }
    let(:test_environment2) { double() }

    subject(:knife) do
      SporkEnvironmentAttributeUnset.new([env_args, 'hello']).tap do |k|
        allow(k).to receive(:run_plugins)
        allow(k.ui).to receive(:msg)
        allow(k).to receive(:unset_attribute).and_return(true)
        allow(k).to receive(:pretty_print_json)
        allow(k).to receive(:save_environment_changes)
        allow(k).to receive_message_chain(:spork_config, :environment_groups => { "test" => [ "TestEnvironment1", "TestEnvironment2" ]})
        allow(k).to receive(:load_environment_from_file).with("TestEnvironment1").and_return(test_environment1)
        allow(k).to receive(:load_environment_from_file).with("TestEnvironment2").and_return(test_environment2)
      end
    end

    before(:each) do
      expect(test_environment1).to receive(:to_hash)
      expect(test_environment1).to receive(:save)
      expect(test_environment2).to receive(:to_hash)
      expect(test_environment2).to receive(:save)

      knife.run
    end

    context '#run' do
      context 'when an environment group is passed' do
        let(:env_args) { 'test' }
        it 'accepts argument'
      end

      context 'when a list of environments is passed' do
        let(:env_args) { 'TestEnvironment1,TestEnvironment2' }
        it 'accepts argument'
      end
    end
  end
end
