require 'pg'
require 'pry'
require_relative 'db/sql_helpers.rb'
require_relative 'utils/auth.rb'

[1, 2, 3].each do |i|
    calculate_front_and_back_course_par i
end

binding.pry