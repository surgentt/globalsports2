set :server_name, "qa.globalsports.net"

role :app, "#{server_name}", :user => 'gsapps'
role :db,  "#{server_name}", :user => 'gsapps', :primary => true
role :web, "#{server_name}", :user => 'gsapps'

set :deploy_to, '/var/apps/globalsports' #"/usr/local/#{application}"
set :ruby_bin, '/usr/local/rvm/rubies/default/bin/ruby' #"/usr/bin/ruby"
set :gem_home, '/usr/local/rvm/rubies/default/lib/ruby/gems/1.8' #"/usr/lib/ruby/gems/1.8"
#set :httpd_path, "/usr/sbin/httpd"
#set :web_port, 80
set :environment, "qa"
set :migrate_env, "qa"

set :branch, "qa_branch"
set :repository_cache, "git_qa_branch"

#set :default_environment, {
#  #'PATH' => "/path/to/.rvm/ree-1.8.7-2009.10/bin:/path/to/.rvm/gems/ree/1.8.7/bin:/path/to/.rvm/bin:$PATH",
#  #'RUBY_VERSION' => 'ruby 1.8.7',
#  'GEM_HOME' => '/path/to/.rvm/gems/ree/1.8.7',
#  'GEM_PATH' => '/path/to/.rvm/gems/ree/1.8.7'
#  'BASH_ENV' => '/etc/bashrc'
#}
