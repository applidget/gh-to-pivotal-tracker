# Github issues to Pivotal Tracker

![](https://circleci.com/gh/applidget/gh-to-pivotal-tracker.png?style=shield&circle-token=378b721a0ca22774a664fe70e4b1a85228fad86a)

Github issues are great. You do miss a few features though, including:
- Ability to order issues 
- Ability to estimate a size/weight/points for an issues
- Ability to have an ETA for a given issue

It turns out pivotal tracker has all these features out of the box

This project is a sinatra app that creates a Pivotal Tracker story whenever a new issue is created. It uses github API to register to `issues` hooks. 

##Run it 

    bundle exec rackup -p $PORT

Or

    foreman start
    
##Required environment variables 
- `PIVOTAL_TRACKER_PROJECT_ID`: the id of
- `PIVOTAL_TRACKER_AUTH_TOKEN`: your api token for pivotal tracker

##Configure github webkhook

Assuming this runs at https://somedomain.com, the webhook you need to configure is : 

- https://somedomaincom/hook
- you need to register for the following events:
  - issue