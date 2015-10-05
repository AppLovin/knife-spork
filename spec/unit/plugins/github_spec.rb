require 'knife-spork/plugins/github'
require 'git'
require 'tempfile'
require 'app_conf'
require 'octokit'

module KnifeSpork::Plugins
  describe Github do
    let(:config) do
      spork_config = Tempfile.open('spork-config.yml')
      spork_config.write(<<-EOF)
      plugins:
        github:
          token: abc123
      EOF
      spork_config.close

      config = AppConf.new
      config.load(spork_config.path)

      config
    end

    let(:github_plugin) do
      options = { :attribute => "some.attribute",
                  :value => "some.value" }

      github = Github.new({ :config => config,
                            :args => options } )
    end

    let(:github) do
      double()
    end

    context "when executing after_environment_attribute_set" do
      it "creates pull request to master" do
        allow(github_plugin).to receive_message_chain(:git, :remote, :url => "git@github.com:owner/repo.git")
        allow(github_plugin).to receive_message_chain(:git, :branch, :url => "git@github.com:owner/repo.git")
        expect(::Octokit::Client).to receive(:new).with(:access_token => "abc123").and_return(github)

        pull_args = [ "owner/repo",
                      "master",
                      "attribute/some.attribute",
                      "Set some.attribute to some.value",
                      "" ]

        expect(github).to receive(:create_pull_request).with(*pull_args)

        github_plugin.after_environment_attribute_set
      end
    end
  end
end
