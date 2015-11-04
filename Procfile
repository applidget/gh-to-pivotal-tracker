web: bundle exec rackup -p $PORT
worker: bundle exec rake resque:work QUEUES=main,gh_update INTERVAL=1 TERM_CHILD=1
worker_milestone: bundle exec rake resque:work QUEUES=milestone,main,gh_update INTERVAL=1 TERM_CHILD=1
scheduler: bundle exec rake resque:scheduler
