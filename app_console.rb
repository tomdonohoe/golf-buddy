require 'pg'
require 'pry'
require_relative 'db/sql_helpers.rb'
require_relative 'utils/auth.rb'

course = find_course_by_name "port kembla"
p course.nil?


binding.pry