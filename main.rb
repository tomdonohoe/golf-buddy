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
  redirect '/session/new'
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
    redirect '/session/new'
  end
end


delete '/session' do
  session[:user_id] = nil
  redirect '/session/new'
end


get '/start-game' do
  courses = get_all_courses
  erb :start_game, locals: {courses: courses}
end


get '/scorecard' do
  course = find_course_by_id params['course_id']
  round_id = params['round_id']

  erb :hole_scoring, locals: {course: course, round_id: round_id}
end


# Rounds
post '/round' do
  course_id = params['course_id']
  user = current_user_details 
  create_new_round user['id'], course_id
  round_id = find_latest_round_id
  
  redirect "/scorecard?course_id=#{course_id}&round_id=#{round_id}"
end

# Courses
get '/course' do
  course = find_course_by_id params['course_id']
  round_id = find_latest_round_id

  erb :course, locals: {course: course, round_id: round_id}
end

post '/course' do
  course = find_course_by_name params['course_name']

  if course.nil?
    create_new_course params['course_name'], params['course_par'], params['num_holes']
    new_course = find_course_by_name params['course_name']
    redirect "/holes?course_id=#{new_course['id']}"
  else
    redirect "/scorecard?course_id=#{course['id']}"
  end
end

# Holes
get '/holes' do
  course = find_course_by_id params['course_id']
  erb :holes, locals: {course: course}
end

post '/holes' do
  course_id = params['course_id']
  create_18_new_holes params, course_id
  redirect "/course?course_id=#{course_id}"
end

# Scores
post '/scores' do
  course_id = params['course_id']
  user_id = params['user_id']
  round_id = params['round_id']

  create_18_new_scores course_id, user_id, round_id, params
  add_total_score_to_round round_id
end
