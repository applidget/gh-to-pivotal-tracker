web: bundle exec rackup -p $PORT
worker: bundle exec rake resque:work QUEUES=main,syncer INTERVAL=1 TERM_CHILD=1
scheduler: bundle exec rake resque:scheduler
