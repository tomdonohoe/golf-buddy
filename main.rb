require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'db/sql_helpers.rb'
require_relative 'utils/auth.rb'
require_relative 'utils/helpers.rb'

enable :sessions


get '/' do
  erb :index
end


get '/user/new' do
  erb :signup
end


get '/user/:id' do
  user = current_user_details
  erb :user_profile, locals: {user: user}
end


get '/user/:id/edit' do
  user = current_user_details 
  erb :edit_user, locals: {user: user}
end


patch '/user/:id' do
  update_user_by_id params['id'], params['username'], params['email']
  redirect "/user/#{params['id']}"
end



post '/user' do
  password_digest = hash_password params['password']
  create_new_user params['username'], params['email'], password_digest
  redirect '/'
end


delete '/user/:id' do
  delete_user_by_id params['id']
  redirect '/'
end


get '/session/new' do
  erb :login
end


post '/session' do
  user = find_user_by_email params['email']
  if authenticate_password? user['password_digest'], params['password']
    session[:user_id] = user['id']
    redirect "/user/#{user['id']}"
  else
    puts 'wrong password'
    redirect '/session/new'
  end
end


delete '/session' do
  session[:user_id] = nil
  redirect '/session/new'
end


