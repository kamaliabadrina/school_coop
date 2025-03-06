Eye.application 'my_school_coop_app' do
    process :rails_server do
      command 'bundle exec rails server'
      daemonize true
      pid_file 'tmp/pids/rails.pid'
      log 'log/eye.log'
    end
  end
  