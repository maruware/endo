# endo

This is a tool for testing json api endpoints.

# Usage

Write endo file.
ex. endo/sample.rb

```ruby
base_url 'http://localhost:3000'
basic_auth 'user', 'pass'

get '/articles' do
  expect(header: 'Content-Type').to equal 'application/json; charset=utf-8'
end

post '/articles.json' do
  param 'article[title]', 'hello'
  param 'article[content]', 'Hello, world!'
end

get '/articles/:article_id' do
  param :article_id do
    from :post, '/articles.json', 'id'
  end

  expect(header: 'Content-Type').to equal 'application/json'
  expect(body: 'title' }).to equal 'hello'
end
```

Exec endo command.

![ss_ 2016-05-02 16 12 58](https://cloud.githubusercontent.com/assets/1129887/14948974/f20798cc-1080-11e6-8b0d-90679c26b44e.png)

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
