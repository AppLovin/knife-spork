$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'x-knife-spork'
  gem.version       = '2.5.1'
  gem.authors       = ["Jeune Asuncion"]
  gem.email         = 'jeunito@gmail.com'
  gem.homepage      = 'https://github.com/jeunito/knife-spork-x'
  gem.licenses      = ['GPL']
  gem.summary       = "A workflow plugin to help many devs work with the same chef repo/server"
  gem.description   = "KnifeSpork is a workflow plugin for Chef::Knife which helps multiple developers work on the same Chef Server and repository without treading on each other's toes."

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "knife-spork-x"
  gem.require_paths = ["lib"]

  
  gem.add_development_dependency 'rspec', '~> 3.1'
  gem.add_development_dependency 'chef-zero', '~> 3.2'
  gem.add_development_dependency 'rack', '~> 1.6' #TODO find a way to not have to deal with this

  gem.add_runtime_dependency 'octokit', '~> 4.0'
  gem.add_runtime_dependency 'chef', '~> 12.0'
  gem.add_runtime_dependency 'git', '~> 1.2'
  gem.add_runtime_dependency 'app_conf', '= 0.4.0'
  gem.add_runtime_dependency 'diffy', '~> 3.0'
end
