set :base_url, 'http://localhost:3000'
basic_auth 'user', 'pass'

get '/articles' do
  expect(header: 'Content-Type').to eq 'application/json; charset=utf-8'
end

post '/articles.json' do
  param 'article[title]', 'hello'
  param 'article[content]', 'Hello, world!'
end

get '/articles/:article_id' do
  param :article_id do
    from :post, '/articles.json', ->{ self[:id] }
  end

  expect(header: 'Content-Type').to eq 'application/json; charset=utf-8'
  expect(body: ->{ self[:title] }).to eq 'hello'
end

patch '/articles/:article_id.json' do
  param :article_id do
    from :post, '/articles.json', ->{ self[:id] }
  end

  param 'article[title]', 'こんにちは'
end

get '/articles/:article_id' do
  param :article_id do
    from :post, '/articles.json', ->{ self[:id] }
  end

  expect(body: ->{ self[:title] }).to eq 'こんにちは'
end

put '/articles/:article_id.json' do
  param :article_id do
    from :post, '/articles.json', ->{ self[:id] }
  end

  param 'article[title]', 'bonjour'
end

delete '/articles/:article_id.json' do
  param :article_id do
    from :post, '/articles.json', ->{ self[:id] }
  end
end