require 'app_conf'
require 'chef/knife/spork-environment-attribute-set'
require 'spec_helper'

module KnifeSpork
  describe SporkEnvironmentAttributeSet do
    let(:stdout_io) { StringIO.new }
    let(:stderr_io) { StringIO.new }

    let(:argv) { [ "example", "hello", "world" ] }

    subject(:knife) do
      SporkEnvironmentAttributeSet.new(argv)
    end

    before(:all) do
      copy_test_data
    end

    after(:all) do
      cleanup_test_data
    end

    describe "#run" do
      before(:each) { set_chef_config }
      it 'calls override_attribute method' do
        expect(knife).to receive(:override_attribute)
        knife.run
      end

      context 'when --no_upload is passed' do
        it 'does not upload environment'
      end
    end

    describe '#hashify' do
      it 'generates nested hash from string' do
        expect(knife.hashify('hello:world', 'test')).to eq({'hello' => { 'world' => 'test' }})
      end
    end
  end
end
