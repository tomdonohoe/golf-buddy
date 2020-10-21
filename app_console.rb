require 'pg'
require 'pry'
require_relative 'db/sql_helpers.rb'
require_relative 'utils/auth.rb'

user = find_user_by_email("tom@gmail.com")
puts authenticate_password? user['password_digest'], "cake"


binding.pry