set :server_name, "qa2.globalsports.net"

role :app, "#{server_name}", :user => 'gsapps'
role :db,  "#{server_name}", :user => 'gsapps', :primary => true
role :web, "#{server_name}", :user => 'gsapps'

set :deploy_to, '/var/apps/globalsports2' #"/usr/local/#{application}"
set :ruby_bin, "/usr/bin/ruby"
set :gem_home, "/usr/lib/ruby/gems/1.8"
set :httpd_path, "/usr/sbin/httpd"
set :web_port, 80
set :environment, "qa2"
set :migrate_env, "qa2"

set :branch, "qa2_branch"
set :repository_cache, "git_qa_branch"
