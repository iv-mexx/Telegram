# Telegram UI Tests

This fork was created to implement some UI Testcases as Proof-of-Concept. 

Testcases are based on [XCode UI Tests](https://developer.apple.com/videos/play/wwdc2015-406/) introduced in Xcode 7.

## Setup

Clone this repo and initialize its submodules (`git clone --recursive`).

### External Dependencies

The testcases depends on some external tools to communicate with the telegram service for triggering actions and verifying results. 

#### Telegram CLI

Install the [Telegram CLI](https://github.com/rnhmjoj/tg). 
On OSX you might need to perform these commands before building (instead of whats listed in the README there): 

```
brew update
brew upgrade
brew install libconfig readline lua python libevent jansson
export CFLAGS="-I/usr/local/include -I/usr/local/Cellar/readline/6.3.8/include"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export LDFLAGS="-L/usr/local/opt/openssl/lib -L/usr/local/lib -L/usr/local/Cellar/readline/6.3.8/lib"
./configure && make
```

Start up the Telegram CLI at least once and setup your account. You should use the same phone number that you will use in your testcases so that the confirmation code is sent to your CLI client when requested from the Testcase. 

Create a new contact with your own number (This can only be done in the CLI and is necessary for the testcases to work properly, the testcases will send messages to yourself, otherwise you would need a second CLI user).

* In the telegram CLI: `add_contact <phone> <first name> <last name>`

#### Telegram UI Test Server

The Testcases need to trigger actions from telegram (e.g. sending a message) or read messages (reading the verification code or verifying that a message was sent correctly).

Clone [the repo](https://github.com/iv-mexx/TelegramUITestRequestServer) and read the instructions to setup the Telegram UI Test Server.

### Caveats

* Simulator is not cleaned after testcases. In order to trigger the Registration, the Simulator has to be reset manually between Test-Runs
* "Send Message" Testcase does not work. Because Telegram uses fully custom UI Elements for the Message-Input, it was not possible to select the input with `XCUIElementQuery` to enter a message text. 
