require 'knife-spork/plugins/git'
require 'octokit'

module KnifeSpork
  module Plugins
    class Github < Git
      name :github
        # g = Git.open('/tmp/hello')
        # g.branch('hello').checkout
        # g.add
        # g.commit
        # g.push("origin", "branch", true)

        # github.pull_request

      def after_environment_attribute_set
        if config.enabled
          github = ::Octokit::Client.new :access_token => config.token

          pull_args = [ "#{/(?<=:).*(?=\.git)/.match(git.remote.url)[0]}",
                        if !config.target_branch.nil?
                          config.target_branch
                        else
                          "master"
                        end,
                        "attribute/some.attribute",
                        "Set #{@options[:args][:attribute]} to #{@options[:args][:value]}",
                        "" ]

          github.create_pull_request(*pull_args)
        end
      end
    end
  end
end
