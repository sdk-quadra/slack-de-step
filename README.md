# Slack De Step
Slack De Stepはslackでメッセージを自動送信するアプリです。

Slackの特定のチャンネルに参加して「**○日目**」の人に送信します。
固定化された新人教育を自動化するなど、一定日数経った人に特別なメッセージを送る場合に利用します。

アプリの利用はもちろん無料です。

## heroku button
[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

heroku buttonを使うには、以下の環境変数の情報が必要です↓


---------

### 環境変数


#### slack 情報
slackとの連携の為。[Create New Appで取得](https://api.slack.com/apps)

情報入力後、Basic Informationの所にあります

* ENV["SLACK_CLIENT_ID"]
* ENV["SLACK_CLIENT_SECRET]


#### AWS情報
画像保存の為。

* ENV["AWS_BUCKET"]
* ENV["AWS_ACCESS_KEY"]
* ENV["AWS_SECRET_ACCESS_KEY"]

※※※ heroku buttonを使ってアプリを立ち上げる場合、ここから下は herokuにdeployしてから実行してください ※※※

* アプリのURLは、`入力したApp name+herokuapp.com`です

  * App nameがcat-and-dogの場合：`https://cat-and-dog.herokuapp.com/`

* herokuの管理画面でdeployしたアプリを選択後、Resourceで
`worker bundle exec sidekiq`
をonにしてください

* herokuの管理画面でdeployしたアプリを選択後、SettingのConfig Varsで
`TZ = Asia/Tokyo`を追加してください（KEYに`TZ`、VALUEに`Asia/Tokyo`）

* もしdeploy to herokuでアプリを立ち上げた時に設定した環境変数の値を変更したいなら、
このSettingのConfig Varsから行ってください


### 権限・認証・スコープ
slack apiの権限・認証・スコープ周りの設定は以下の通りです。

上記の [Create New Appで取得](https://api.slack.com/apps) の時に、Permissions（OAuth & Permissions）と Event Subscriptions
を 以下の様に設定してください

この設定を行う時、chromeの翻訳機能でページが日本語化されているとエラーになるので注意してください。

#### OAuth & Permissions

##### OAuth Tokens & Redirect URLs
`install to workspace`をクリックして、tokenを発行してください（先に以下のScopesを設定している必要があります）

##### Redirect URLs
`/auth/slack/callback`を指定してください。

例：`https://your.app.com/auth/slack/callback`

##### Scopes
スコープには以下を指定してください

###### Bot Token Scopes

* channels:history
* channels:join
* channels:read
* chat:write
* files:write
* groups:read
* im:history
* im:read
* team:read
* users:read


###### User Token Scopes

* identity.avatar
* identity.basic
* identity.email
* identity.team




#### Event Subscriptions

Enable Events をonにしてから、以下を設定してください

##### Request URL
`/server`を指定してください

例：`https://your.app.com/server`


###### Subscribe to bot events

* app_home_opened
* channel_created
* channel_deleted
* channel_left
* channel_rename
* channel_archive
* channel_unarchive
* member_joined_channel
* member_left_channel
* message.im
* team_join


---------

#### Manage distribution

Manage distributionでアプリの配布設定をします。

Remove Hard Coded Informationの
`I’ve reviewed and removed any hard-coded information.`
にcheckを入れて、`Activate Public Distribution`をクリックしてください

---------


以上ここまででアプリを使えるようになっているはずです。


もしそれでもページが表示されないなら、環境変数の値が間違っている可能性があります。
その場合は、herokuの管理画面のsettingから、環境変数を修正してください。



---------

※※※ ここから下は、localで動かす際の情報です ※※※

### メッセージ送信
多数のメッセージを捌く為、sidekiqを使用しています。redisとsidekiqを起動してください

* redisを起動後、
* $ bundle exec sidekiq
---------


### イベント受信
slack上で発生したイベントを受信する為に、[ngrok](https://api.slack.com/tutorials/tunneling-with-ngrok) の利用を推奨

ngrokを使う場合は、上記で触れた`Redirect URLs`と`Request URL`をngrokが発行したURLに書き換えてください

Redirect URLs例：`https://66ab700b7e7d.ngrok.io/auth/slack/callback`

Request URL例：`https://66ab700b7e7d.ngrok.io/server`


---------

### テスト

localでテストを実行するには、上記の環境変数5つに加え、追加で以下の3つの環境変数設定が必要です。

`$ rails c` して以下を行います。

```
irb> len = ActiveSupport::MessageEncryptor.key_len

irb> salt = SecureRandom.hex(len)

irb> token = "<※注１>"

irb> encrypted_token = App.encrypt_token(salt, token)

irb> app_name = "<※注２>"

irb> bot_user_id = App.bot_user_id(token, app_name)
```
※注１：上記の [Create New Appで取得](https://api.slack.com/apps) の
OAuth & Permissionsにある、`xoxb-`で始まる Bot User OAuth Access Token を指定してください

※注２：上記の [Create New Appで取得](https://api.slack.com/apps) の
Basic Information > Display Information の App nameにある名前 を指定してください

上記で生成した`salt`を ENV["SALTED_KEY"]に、

`encrypted_token` を ENV["OAUTH_BOT_TOKEN"]に、

`bot_user_id` を ENV["BOT_USER_ID"]に入れてからテストを実行してください

テストはrspecです

`$ bundle exec rspec spec`




---------


### その他

##### 送信対象
SlackとSlack De Stepを連携してから「以降」にチャンネルに参加した人が対象。

連携時、すでにチャンネルに参加している人に対して、遡って対象にする事はできません。



---------

### License
ライセンスは [MIT license](https://github.com/cobyism/ghost-on-heroku/blob/master/LICENSE) です。


