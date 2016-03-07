# endo

This is a tool for testing api endpoints.
In development state.

# Usage

Write endo file.
ex. endo/sample.endo

```ruby
set :base_url, 'http://endo-sample.maruware.com'

get '/articles' do
  expect(body: ->{ at(0)[:title] }).to eq 'good'
end

get '/articles/:article_id' do
  param :article_id do
    from :get, '/articles', ->{ first[:id] }
  end

  expect(header: 'Content-Type').to eq 'application/json; charset=utf-8'
end

post '/articless' do
  param :title, 'hello'
  param :text, 'Hello, world!'
end
```

Exec endo command.

![2016-03-07 21 24 08](https://cloud.githubusercontent.com/assets/1129887/13569450/7d9a796a-e4ab-11e5-9ab0-e52eef36ea0f.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'endo'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install endo
```