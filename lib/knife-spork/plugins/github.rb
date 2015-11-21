require 'octokit'
require 'knife-spork/plugins/plugin'

module KnifeSpork
  module Plugins
    class Github < Plugin
      name :github

      def after_environment_attribute_set
        if config.enabled
          github = ::Octokit::Client.new :access_token => config.token

          pull_args = [ "#{/(?<=:).*(?=\.git)/.match(git.remote.url)[0]}",
                        if !config.target_branch.nil?
                          config.target_branch
                        else
                          "master"
                        end,
                        git.current_branch.name,
                        "Set #{@options[:args][:attribute]} to #{@options[:args][:value]}",
                        "" ]

          github.create_pull_request(*pull_args)
        end
      end
      
      private
      def git
        safe_require 'git'
        log = Logger.new(STDOUT)
        log.level = Logger::WARN
        @git ||= begin
          cwd = FileUtils.pwd()
          ::Git.open(get_parent_dir(cwd) , :log => log)
        rescue Exception => e  
          ui.error "You are not currently in a git repository #{cwd}. Please ensure you are in a git repo, a repo subdirectory, or remove the git plugin from your KnifeSpork configuration!"
          exit(0)
        end
      end

      def get_parent_dir(path)
        top_level = path
        return_code = 0
        while return_code == 0
          output = IO.popen("cd #{top_level}/.. && git rev-parse --show-toplevel 2>&1")
          Process.wait
          return_code = $?
          cmd_output = output.read.chomp
          #cygwin, I hate you for making me do this
          if cmd_output.include?("fatal: Not a git repository")
            return_code = 1
          end
          if return_code == 0
            top_level = cmd_output
          end
        end
        top_level
      end
    end
  end
end
