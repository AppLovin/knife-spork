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
      let(:config) do
        config = AppConf.new
        config.from_hash({
          'plugins' => {
            'git' => {
              'enabled' => true
            }
          }
        })

        config
      end

      let(:git_plugin) do
        g = Git.new(:config => config)

        allow(g).to receive(:environment_path).and_return '/path/to/environments'
        allow(g).to receive(:git_branch)
        allow(g).to receive(:git_add)
        allow(g).to receive(:git_commit)
        allow(g).to receive(:git_push)
        allow(g).to receive(:github_pull_request)

        allow(g).to receive(:args).and_return({
          :environments => ['TestEnvironment'],
          :attribute => 'hello',
          :value => 'world'
        })

        g
      end

      after(:each) do
        git_plugin.after_environment_attribute_set
      end

      context "when default options are used" do
        it 'creates a new branch' do
          expect(git_plugin).to receive(:git_branch).with 'attribute/hello'
        end

        it 'adds environment modified' do
          expect(git_plugin).to receive(:git_add).with '/path/to/environments', 'TestEnvironment.json'
        end

        it 'commits changes to environment files' do
          expect(git_plugin).to receive(:git_commit).with '/path/to/environments', 'Set hello to world in TestEnvironment'
        end 

        it 'pushes branch to remote' do
          expect(git_plugin).to receive(:git_push).with 'attribute/hello'
        end
      end

      context 'when git branch is set' do
        it 'pushes changes to remote repo' do
          config.plugins.git['branch'] = 'master'

          expect(git_plugin).to receive(:git_branch).with('master')
          expect(git_plugin).to receive(:git_push).with 'master'
        end
      end

      context "when github is enabled" do
        it "creates pull request to master" do
          config.plugins.git['github'] = {}

          expect(git_plugin).to receive(:github_pull_request).with('Set hello to world in TestEnvironment', 'attribute/hello')
        end
      end
    end
  end
end
