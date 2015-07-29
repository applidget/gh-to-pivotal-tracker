#Github issues to Pivotal Tracker

Github issues are great. You do miss a few features though, including:
- Ability to order issues 
- Ability to estimate a size/weight/points for an issues
- Ability to have an ETA for a given issue

It turns out pivotal tracker has all these features out of the box

This project is a sinatra app that creates a Pivotal Tracker story whenever a new issue is created. It uses github API to register to `issues` hooks. 