require 'knife-spork/plugins/git'
require 'app_conf'
require 'tempfile'
require 'git'
require 'octokit'

module KnifeSpork::Plugins
  describe Git do
    let(:args) do
      {
        :environments => ['TestEnvironment'],
        :attribute => 'hello',
        :value => 'world'
      } 
    end

    let(:config) do
      config = AppConf.new
      config.from_hash({
        'plugins' => {
          'git' => {
            'enabled' => true,
            'auto_push' => {
              'disabled' => [
                'after_envgroup_attribute_set' 
              ]
            }
          }
        }
      })

    end

    let(:git_plugin) do
      Git.new(:config => config).tap do |g|
        allow(g).to receive(:environment_path).and_return '/path/to/environments'
        allow(g).to receive(:git_branch)
        allow(g).to receive(:git_add)
        allow(g).to receive(:git_commit)
        allow(g).to receive(:git_push)
        allow(g).to receive(:github_pull_request)
        allow(g).to receive(:args).and_return(args)
      end
    end

    it "checks if hook is allowed to auto_push" do
      expect(git_plugin.auto_push_disabled?(:after_envgroup_attribute_set)).to eq true
    end

    describe "create_github_pull_request" do
      before(:each) do
        allow(git_plugin).to receive_message_chain(:config, :github, :token => 'abc123')
      end

      after(:each) do
        git_plugin.github_pull_request('target_branch', 'some_commit')
      end

      context 'when pull request exists' do
        it 'does not create a pull request' do
          allow(git_plugin).to receive(:pull_requested?).and_return(true)

          expect_any_instance_of(::Octokit::Client).to_not receive(:create_pull_request)
        end
      end

      context 'when pull request does not exist' do
        it 'creates a pull request' do
          allow(git_plugin).to receive(:pull_requested?).and_return(false)
          allow(git_plugin).to receive_message_chain(:git, :remote, :url => 'git@github.com:some_repo.git')
          allow(git_plugin).to receive(:github_pull_request).and_call_original
          expect_any_instance_of(::Octokit::Client).to receive(:create_pull_request)
        end
      end
    end

    describe 'pull_requested?' do
      let(:pull_requests) do
        [
          {:head => {:ref => 'some_branch'}, :base => { :ref => 'master'}},
          {:head => {:ref => 'attribute/hello'}, :base => { :ref => 'master'}}
        ]
      end
      
      context 'when there is a pull request' do
        it 'returns true' do
          expect(git_plugin).to receive_message_chain(:github, :pull_requests => pull_requests ).with('Owner/Repo', :state => 'open')
          expect(git_plugin).to receive_message_chain(:git, :remote, :url => 'git@github.com:Owner/Repo.git')

          expect(git_plugin.pull_requested?('attribute/hello', 'master')).to eq(true)
        end
      end

      context 'when there is no pull request' do
        it 'returns false' do
          expect(git_plugin).to receive_message_chain(:github, :pull_requests => pull_requests ).with('Owner/Repo', :state => 'open')
          expect(git_plugin).to receive_message_chain(:git, :remote, :url => 'git@github.com:Owner/Repo.git')

          expect(git_plugin.pull_requested?('some_other_branch', 'master')).to eq(false)
        end
      end
    end

    describe 'before_environment_attribute_set' do
      after(:each) do
        git_plugin.before_environment_attribute_set
      end

      it 'creates a new branch' do
        expect(git_plugin).to receive(:git_branch).with 'attribute/hello'
      end

      context 'when git branch is set' do
        it 'pushes changes to remote repo' do
          config.plugins.git['branch'] = 'master'

          expect(git_plugin).to receive(:git_branch).with('master')
        end
      end
    end

    describe "after_environment_attribute_set" do
      before(:each) do
        allow(git_plugin).to receive(:auto_push_disabled?).and_return(false)
      end

      after(:each) do
        git_plugin.after_environment_attribute_set
      end

      context "when default options are used" do
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

      context "when github is enabled" do
        it "creates pull request to master" do
          config.plugins.git['github'] = {}

          expect(git_plugin).to receive(:github_pull_request).with('Set hello to world in TestEnvironment', 'attribute/hello')
        end
      end
    end
  end
end
