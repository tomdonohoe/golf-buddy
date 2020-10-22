require 'pg'
require_relative '../utils/auth.rb'

def run_sql query, params = []
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'golf_buddy'})
    result = db.exec_params query, params
    db.close
    result
end


def get_all_courses
    query = "SELECT * FROM courses;"
    run_sql query
end


def create_new_user username, email, password_digest
    query = "INSERT INTO users (username, email, password_digest) VALUES ($1, $2, $3);"
    run_sql query, [username, email, password_digest]
end


def create_new_round user_id, course_id
    current_date = Time.now.strftime("%Y/%m/%d")
    query = "INSERT INTO rounds (created_at, user_id, course_id) VALUES ($1, $2, $3);"
    run_sql query, [current_date, user_id, course_id]
end


def create_new_course name, par, num_holes
    query = "INSERT INTO courses (name, par, num_holes) VALUES ($1, $2, $3);"
    run_sql query, [name, par, num_holes]
end


def create_new_hole number, par, course_id
    query = "INSERT INTO holes (number, par, course_id) VALUES ($1, $2, $3);"
    run_sql query, [number, par, course_id]   
end


def create_18_new_holes params, course_id
    18.times do |i|
        hole_number = i + 1
        create_new_hole hole_number, params["hole_#{hole_number}_par"], course_id
      end
end


def create_new_score hole_number, course_id, user_id, round_id, score
    query = "INSERT INTO scores (user_id, round_id, hole_id, score) VALUES ($1, $2, $3, $4);"
    query_hole_id = "SELECT id FROM holes WHERE course_id = $1 AND number = $2"
    hole_id = run_sql query_hole_id, [course_id, hole_number] 
    run_sql query, [user_id, round_id, hole_id[0]['id'], score]   
end


def create_18_new_scores course_id, user_id, round_id, params
    18.times do |i|
        hole_number = i + 1
        score = params["hole_#{hole_number}_score"]
        create_new_score hole_number, course_id, user_id, round_id, score
    end
end


def find_user_by_email email
    query = "SELECT * FROM users WHERE email = $1;"
    result = run_sql query, [email]
    result.first
end


def find_user_by_id id
    query = "SELECT * FROM users WHERE id = $1;"
    result = run_sql query, [id]
    result.first
end


def find_course_by_id id
    query = "SELECT * FROM courses WHERE id = $1;"
    result = run_sql query, [id]
    result.first
end


def find_course_by_name name
    query = "SELECT * FROM courses WHERE name = $1;"
    result = run_sql query, [name]
    result.first
end


def find_round_by_id id
    query = "SELECT * FROM rounds WHERE id = $1;"
    result = run_sql query, [id]
    result.first
end


def find_latest_round_id
    query = "SELECT id FROM rounds ORDER BY id DESC LIMIT 1;"
    result = run_sql query
    result.first['id']
end


def delete_user_by_id id
    query = "DELETE FROM users WHERE id = $1;"
    result = run_sql query, [id]
end


def update_user_by_id id, username, email
    query = %{
        UPDATE users
        SET username = $1, email = $2
        WHERE id = $3;
    }
    run_sql query, [username, email, id]
end


def add_total_score_to_round round_id
    total_score_query = "SELECT SUM(score) as total FROM scores WHERE round_id = $1"
    total_score = run_sql total_score_query, [round_id]

    query = "UPDATE rounds SET total_score = $1 WHERE id = $2"
    run_sql query, [total_score[0]['total'], round_id]
end