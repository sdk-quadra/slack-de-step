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

localで動かすには、以下の環境変数のセットが必要です。

#### slack 情報
slackとの連携の為。[Create New Appで取得](https://api.slack.com/apps)

* ENV["SLACK_CLIENT_ID"]
* ENV["SLACK_CLIENT_SECRET]

#### salt
slack token暗号化の為。長さは32byte

* ENV["SALTED_KEY"]

#### AWS情報
画像保存の為。

* ENV["AWS_ACCESS_KEY"]
* ENV["AWS_SECRET_ACCESS_KEY"]

--------



### メッセージ送信
多数のメッセージを捌く為、sidekiqを使用

* $ redis-server
* $ bundle exec sidekiq
---------


### イベント受信
開発時は、slack上で発生したイベントを受信する為に、[ngrok](https://api.slack.com/tutorials/tunneling-with-ngrok) の利用を推奨

---------


### 送信対象
SlackとSlack De Stepを連携してから「以降」にチャンネルに参加した人が対象。

連携時、すでにチャンネルに参加している人に対して、遡って対象にする事はできません。


---------

### テスト
$ bundle exec rspec spec

---------

### 権限・認証・スコープ
slack apiの権限・認証・スコープ周りの設定は以下の通りです。

この設定を行う時、chromeの翻訳機能でページが日本語化されているとエラーになるので注意してください。

#### OAuth & Permissions

##### Bot Token Scopes

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


##### User Token Scopes

* identity.avatar
* identity.basic
* identity.email
* identity.team


#### Event Subscriptions

##### Subscribe to bot events

* app_home_opened
* channel_created
* channels:read
* channel_deleted
* channels:read
* channel_left
* channels:read
* channel_rename
* channels:read
* member_joined_channel
* channels:read or groups:read
* member_left_channel
* channels:read or groups:read
* message.im
* im:history
* team_join
* users:read


---------

### License
ライセンスは [MIT license](https://github.com/cobyism/ghost-on-heroku/blob/master/LICENSE) です。


