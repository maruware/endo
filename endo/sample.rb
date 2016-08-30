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
  param 'article_id' do
    from 'post', '/articles.json', 'id'
    # or
    # from :post, '/articles.json', -> { self['id'] }

    # or
    # from :post, '/articles.json' do |r|
    #   r['id']
    # end
  end

  expect(header: 'Content-Type').to equal 'application/json; charset=utf-8'
  expect(body: 'title').to equal 'hello'
end

patch '/articles/:article_id.json' do
  param 'article_id' do
    from :post, '/articles.json', 'id'
  end

  param 'article[title]', 'こんにちは'
end

get '/articles/:article_id' do
  param 'article_id' do
    from :post, '/articles.json', 'id'
  end

  expect(body: 'title').to equal 'こんにちは'
end

put '/articles/:article_id.json' do
  param 'article_id' do
    from :post, '/articles.json', 'id'
  end

  param 'article[title]', 'bonjour'
end

delete '/articles/:article_id.json' do
  param :article_id do
    from :post, '/articles.json', 'id'
  end
end
