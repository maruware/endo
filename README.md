# endo

This is a tool for testing api endpoints.
In development state.

# Usage

Write endo file.
ex. endo/sample.endo

```ruby
set :base_url, 'http://endo-sample.maruware.com'

get '/articles'

get '/articles/:article_id' do
  param 'article_id' do
    from :get, '/articles' do |articles|
      articles.first[:id]
    end
  end
end

post '/articles' do
  param 'title', 'hello'
  param 'text', 'Hello, world!'
end
```

Exec endo command.

```
$ endo exec endo/sample.endo
🍺 /articles [142ms]
🍺 /articles/1 [31ms]
🍺 /articles [28ms]
```

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