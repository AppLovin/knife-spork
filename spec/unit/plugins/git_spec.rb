require 'knife-spork/plugins/git'
require 'app_conf'
require 'tempfile'
require 'git'

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


    describe "after_environment_attribute_set" do
      let(:mock_git) do
        double()
      end

      let(:config) do
        require 'json'

        config = AppConf.new
        config.from_hash(JSON.parse(<<-EOF)) 
        {
          "plugins": {
            "git": {
              "auto_push": true
            }
          }
        }
        EOF

        config
      end

      before(:each) do 
        allow(Time).to receive_message_chain(:now, :getutc, :to_i => 1)
      end

      context "when default options are used" do
        it "pushes changes to remote repo" do
          git_plugin = Git.new( :config => config,
                                :args => {  :attribute => 'some.attribute',
                                            :value => 'some_value',
                                            :environments => [ 'TestEnvironment' ]},
                                :environment_path => '/path/to/environments')

          expect(git_plugin).to receive(:git_branch).with("attribute/some.attribute_1")
          expect(git_plugin).to receive(:git_add).with('/path/to/environments', 'TestEnvironment.json')
          expect(git_plugin).to receive(:git_commit).with('/path/to/environments', 'Set some.attribute to some_value in TestEnvironment')
          expect(git_plugin).to receive(:git_push).with("attribute/some.attribute_1")

          git_plugin.after_environment_attribute_set
        end
      end

      context "when git branch is set" do
        it "pushes changes to remote repo" do
          config.plugins.git['branch'] = 'master'

          git_plugin = Git.new( :config => config,
                                :args => {  :attribute => 'some.attribute',
                                            :value => 'some_value',
                                            :environments => [ 'TestEnvironment' ]},
                                :environment_path => '/path/to/environments')

          expect(git_plugin).to receive(:git_branch).with("master")
          expect(git_plugin).to receive(:git_add).with('/path/to/environments', 'TestEnvironment.json')
          expect(git_plugin).to receive(:git_commit).with('/path/to/environments', 'Set some.attribute to some_value in TestEnvironment')
          expect(git_plugin).to receive(:git_push).with("master")

          git_plugin.after_environment_attribute_set
        end
      end
    end
  end
end
