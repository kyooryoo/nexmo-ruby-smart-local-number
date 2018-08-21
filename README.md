# Smart Local Numbers Solution with Ruby
Replace expensive toll-free 800 numbers with multiple local numbers

## Prerequisites
* A [Nexmo account](https://dashboard.nexmo.com/sign-up)
* The [Nexmo CLI](https://github.com/Nexmo/nexmo-cli) installed
* Run a local server on a public port, for example [Ngrok](https://ngrok.com/).
* [Ruby 2.1+](https://www.ruby-lang.org/) and [Bundler](http://bundler.io/)

## Stey by Step Guide
1. Reuse the source code
```sh
git clone git@github.com:kyooryoo/nexmo-ruby-800-replacement.git
cd nexmo-ruby-800-replacement
rvm rvmrc warning ignore allGemfiles
rvm install "ruby-2.4.1"
rvm docs generate-ri
bundle install
cp .env.example .env
```
2. Open local 4567 port to the Internet, note down returned ngrok_url
```sh
./ngrok http 4567
```
3. Prepare two Nexmo numbers on nexmo.com dashboard, API, or Nexmo CLI
```sh
nexmo number:buy 1312* -c US  --confirm
Number purchased: 1312???????
nexmo number:buy 1415* -c US  --confirm
Number purchased: 1415???????
```
4. Create a Nexmo application and link it to the two numbers
```sh
nexmo app:create "800-Replace" [ngrok_url]/answer [ngrok_url]/event --keyfile private.key
Application created: 7e80ce78-????-????-????-2f33b4366fc7
Private Key saved to: private.key
nexmo link:app 1312??????? 7e80ce78-????-????-????-2f33b4366fc7
nexmo link:app 1415??????? 7e80ce78-????-????-????-2f33b4366fc7
```
5. Fill in the values in `.env` as appropriate
* `INBOUND_NUMBER_1` and `INBOUND_NUMBER_2` are the two Nexmo numbers
* `DOMAIN` is the public domain [ngrok_url] we get from ngrok
6. Run the server
```sh
ruby app.rb
```
7. Test out by calling the two Nexmo numbers
* Nexmo will then make a call to `http://your.domain/answer`
* The server plays back a message for the city you just called a local number for
* You can play back the messages for the other cities after a prompt

## Reference:
* Tutorial Page https://developer.nexmo.com/tutorials/smart-local-numbers
* GitHub Page https://github.com/Nexmo/800-replacement
