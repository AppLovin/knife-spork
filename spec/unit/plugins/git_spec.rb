require 'knife-spork/plugins/git'
require 'app_conf'
require 'tempfile'

module KnifeSpork::Plugins
  describe Git do
    it "checks if hook is allowed to auto_push" do
      Tempfile.open('config.yml') do |f|
        f.write(<<-EOF)
        plugins:
          git:
            auto_push:
              disabled:
                - after_envgroup_attribute_set
        EOF

        f.close

        config = AppConf.new
        config.load(f.path)

        git_plugin = Git.new(:config => config)
        expect(git_plugin.auto_push_disabled?(:after_envgroup_attribute_set)).to eq true
      end
    end
  end
end
