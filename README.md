# Sample for testing Telegram with Calabash

## Setup

### Dependencies

Dependencies are added as git submodules. 

Run `git submodule init && git submodule update` after cloning this repo to install dependencies.

After that, the project should compile and run. 

### Calabash

On the `calabash` branch, the necessary Project-Setup as described [here](https://github.com/calabash/calabash-ios/wiki/Tutorial%3A-Link-Calabash-in-Debug-config) is already done, but you will need to install calabash. 

* run `bundle`

Open Xcode project and build the app. Then you'll need to tell calabash where the product is located. 
In the Xcode Project Navigator, open the "Products" folder, right click "Telegram.app" and choose "Show in Finder". 
Following [Step 2](https://github.com/calabash/calabash-ios#step-2-run-cucumber-against-an-ios-simulator) you will have to run
` export APP="<Path to the Telegram.app Product>"`

After that, run `bundle exec cucumber` to confirm everything is working. It takes a while for cucumber to launch the simulator, but after some time, you should see output similar to 

```
Feature: Sample Feature

  Scenario: Sample Scenario          # features/sample.feature:3
    Given the app has launched       # features/steps/sample_steps.rb:1
    And I have done a specific thing # features/steps/sample_steps.rb:7
    When I do something              # features/steps/sample_steps.rb:32
    Then something should happen     # features/steps/sample_steps.rb:41

1 scenario (1 passed)
4 steps (4 passed)
0m56.259s
```

Now you are ready to write your own tests without the need of working in the iOS source code.