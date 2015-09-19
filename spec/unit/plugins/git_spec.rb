require 'knife-spork/plugins/git'
require 'app_conf'

module KnifeSpork::Plugins
  describe Git do
    it "checks if hook is allowed to auto_push" do
      config = AppConf.new
      config.from_hash({
        :plugins => {
          :git => {
            :auto_push => {
              :blacklist => [
                "after_envgroup_attribute_set"
              ]
            }
          }
        }
      })

      git_plugin = Git.new(:config => config)
      expect(git_plugin.auto_push_disabled?("after_envgroup_attribute_set")).to eq true
    end
  end
end
