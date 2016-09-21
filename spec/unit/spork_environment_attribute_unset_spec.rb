require 'chef/knife/spork-environment-attribute-unset'
require 'spec_helper'

module KnifeSpork
  describe SporkEnvironmentAttributeUnset do
    before(:each) { copy_test_data }
    after(:each) { cleanup_test_data }

    let(:env_args) { nil }

    subject(:knife) do
      SporkEnvironmentAttributeUnset.new([env_args, 'hello'])
    end

    describe '#run' do
      let(:test_environment) { double() }

      before(:each) do
        expect(test_environment1).to receive(:to_hash).at_least(:once)
        expect(test_environment1).to receive(:save).at_least(:once)
        expect(knife).to receive(:run_plugins)
        expect(knife.ui).to receive(:msg)
        expect(knife).to receive(:unset_attribute).and_return(true)
        expect(knife).to receive(:pretty_print_json)
        expect(knife).to receive(:save_environment_changes)
        expect(knife).to receive_message_chain(:spork_config, :environment_groups => { "test" => [ "TestEnvironment1", "TestEnvironment2" ]})
        expect(knife).to receive(:load_environment_from_file).with("TestEnvironment1").and_return(test_environment1)
        expect(knife).to receive(:load_environment_from_file).with("TestEnvironment2").and_return(test_environment2)
      end

      before(:each) { knife.run }
      context 'when an environment group is passed' do
        let(:env_args) { 'test' }
        it 'accepts argument'
      end

      context 'when a list of environments is passed' do
        let(:env_args) { 'TestEnvironment1,TestEnvironment2' }
        it 'accepts argument'
      end
    end

    describe '#unset' do
      before(:each) { set_chef_config }
      before(:each) do
        allow(knife).to receive(:environment_path).and_return(knife.config[:environment_path])
      end

      let(:environment) do 
        {}.merge(knife.load_environment_from_file('example').tap do |e|
          e.override_attributes({
            'the' => {
              'quick' => 'brown'
            }
          })
        end)
      end
    
      context 'attribute exists' do
        it 'deletes attribute given nested attribute' do
          expect(knife.unset('the:quick', environment)).to_not eq(nil)
          expect(environment['override_attributes']['the']['quick']).to eq(nil)
        end
      end

      context 'attribute does not exist' do
        it 'does nothing' do
          expect(knife.unset('no:such:attribute', environment['override_attributes'])).to eq(nil)
        end
      end
    end
  end
end
