base_url 'http://localhost:3000'
basic_auth 'user', 'pass'

email = "#{SecureRandom.hex(8)}@example.com"

post '/users' do
  param 'email', email
  param 'password', 'secret'
end

get '/users/login' do
  param 'email', email
  param 'password', 'secret'
end

post '/articles' do
  param 'token' do
    from :get, '/users/login', 'token'
  end
  param 'title', 'hello'
  param 'content', 'Hello, world!'
end

get '/articles' do
  expect(header: 'Content-Type').to equal 'application/json; charset=utf-8'
end

delete '/articles/:article_id' do
  param :article_id do
    from :post, '/articles', 'id'
  end
  param 'token' do
    from :get, '/users/login', 'token'
  end
end

get '/users/:user_id/articles' do
  param :user_id do
    from :get, '/users/login', 'id'
  end
end