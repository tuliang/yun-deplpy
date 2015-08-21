# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'yun-deploy-rails'
set :deploy_user, 'root'
set :repo_url, 'https://github.com/tuliang/yun-deploy-rails.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, "/home/#{fetch(:deploy_user)}/apps/#{fetch(:application)}"

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  task :restart do
    on roles(:web), in: :sequence, wait: 3 do
      within release_path do
        execute 'echo "stop ===>"'
        execute "docker kill $(docker ps -q)"
        
        execute 'echo "start ===>"'
        execute "cd #{release_path} && docker-compose build && docker-compose up -d"
      end
    end
  end

  task :install do
    on roles(:app) do
      base_install
      docker_install
      docker_compose_install
    end
  end

  def base_install
    execute "sudo apt-get update"
    execute "sudo apt-get install -y curl"
  end

  def docker_install
    execute "curl -sSL https://get.docker.com/ | sh"
    execute "docker -v"
  end

  def docker_compose_install
    execute "apt-get -y install python-pip"
    execute "pip install -U docker-compose"
    execute "chmod +x /usr/local/bin/docker-compose"
    execute "docker-compose -v"
  end

  after :published, :restart
end