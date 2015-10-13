require 'knife-spork/runner'
require 'chef/knife/spork-bump'

module KnifeSpork
  describe Runner do
    it 'creates new instance of AppConf for a config of higher precendence' do

      spork_config = File.join([ File.expand_path(File.dirname(__FILE__)), "fixtures/config/spork-config.yml" ])

      command = SporkBump.new
      command.class.send(:include, Runner)

      allow(command).to receive(:cookbook_path).and_return(File.expand_path("."))
      allow(command).to receive(:load_paths).and_return([ spork_config, spork_config ])

      mock_conf = double()
      allow(mock_conf).to receive(:load)

      expect(AppConf).to receive(:new).exactly(3).times.and_return(mock_conf)

      command.spork_config

    end
  end
end
