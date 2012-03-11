env = ENV["RAILS_ENV"] || "development"

worker_processes 4
working_directory "/var/www/alwaysresolve.net/current"

# This loads the application in the master process before forking
# worker processes
# Read more about it here:
# http://unicorn.bogomips.org/Unicorn/Configurator.html
preload_app true

timeout 30

# This is where we specify the socket.
# We will point the upstream Nginx module to this socket later on
listen "/var/www/alwaysresolve.net/shared/tmp/unicorn.sock", :backlog => 64

pid "/var/www/alwaysresolve.net/shared/tmp/pids/unicorn.pid"

# Set the path of the log files inside the log folder of the testapp
stderr_path "/var/www/alwaysresolve.net/shared/log/unicorn.stderr.log"
stdout_path "/var/www/alwaysresolve.net/shared/log/unicorn.stdout.log"

# Production specific settings
if env == "production"
  # Help ensure your application will always spawn in the symlinked
  # "current" directory that Capistrano sets up.
  working_directory "/var/www/alwaysresolve.net/current"

  # feel free to point this anywhere accessible on the filesystem
  user 'deploy', 'deploy'
  shared_path = "/var/www/alwaysresolve.net/shared"

  stderr_path "#{shared_path}/log/unicorn.stderr.prod.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.prod.log"
end

before_fork do |server, worker|
# This option works in together with preload_app true setting
# What is does is prevent the master process from holding
# the database connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  old_pid = "/var/www/alwaysresolve.net/current/tmp/pids/unicorn.pid"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
        # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
# Here we are establishing the connection after forking worker
# processes
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
