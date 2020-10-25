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


def get_all_rounds_by_user_id user_id
    query = %{
        SELECT r.id AS round_id,
               r.created_at AS date,
               r.total_score,
               r.course_id,
               c.name,
               c.par,
               c.num_holes 
          FROM rounds as r
          LEFT JOIN courses as c
            ON r.course_id = c.id
         WHERE user_id = $1
         ORDER BY date DESC;
    }
    run_sql query, [user_id]
end


def get_round_by_user_id_round_id user_id, round_id
    query = %{
        SELECT r.id AS round_id,
               r.created_at AS date,
               r.total_score,
               r.front_9_total_score,
               r.back_9_total_score,
               r.user_id,
               r.course_id,
               c.name AS course_name,
               c.par AS course_par,
               c.front_9_par,
               c.back_9_par,
               c.num_holes,
               h.number AS hole_number,
               h.par AS hole_par,
               s.id AS score_id,
               s.score AS user_score
          FROM rounds AS r
          LEFT JOIN courses AS c
            ON r.course_id = c.id
          LEFT JOIN holes AS h
            ON c.id = h.course_id
          LEFT JOIN scores AS s
            ON s.round_id = r.id AND s.hole_id = h.id
         WHERE r.user_id = $1 and r.id = $2;
    }
    result = run_sql query, [user_id, round_id]
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


def create_friend logged_in_user_id, friend_user_id
    query = "INSERT INTO friends (user_id, friend_id) VALUES ($1, $2);"
    run_sql query, [logged_in_user_id, friend_user_id]
end


def create_new_post user_id, username, round_date, course_name, course_par, user_total_score
    query = %{
        INSERT INTO posts (
            user_id, 
            username, 
            round_date, 
            course_name, 
            course_par, 
            user_total_score
        )
        VALUES (
            $1, 
            $2, 
            $3, 
            $4,
            $5,
            $6
        );
    }
    run_sql query, [user_id, username, round_date, course_name, course_par, user_total_score]
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


def find_friend_ids_by_user_id user_id
    query = "SELECT friend_id FROM friends WHERE user_id = $1;"
    run_sql query, [user_id]
end


def find_friends_by_id current_user_id, friend_id
    query = "SELECT * FROM friends WHERE user_id = $1 AND friend_id = $2;"
    run_sql query, [current_user_id, friend_id]
end   


def find_all_posts_by_user_id user_id
    query = "SELECT * FROM posts WHERE user_id = $1;"
    run_sql query, [user_id]
end


def find_all_posts_by_friend_ids friend_ids
    # format of friend_ids must be 
    query = "SELECT * FROM multiple_users_ids(VARIADIC $1::int[]);"
    run_sql query, [friend_ids]
end


def delete_user_by_id id
    query = "DELETE FROM users WHERE id = $1;"
    result = run_sql query, [id]
end


def delete_round_by_id id
    query_rounds = "DELETE FROM rounds WHERE id = $1;"
    query_scores = "DELETE FROM scores WHERE round_id = $1;"
    run_sql query_rounds, [id]
    run_sql query_scores, [id]
end

def delete_friend user_id, friend_id
    query = "DELETE FROM friends WHERE user_id = $1 AND friend_id = $2"
    run_sql query, [user_id, friend_id]
end


def delete_post_by_id post_id
    query = "DELETE FROM posts WHERE id = $1;"
    run_sql query, [post_id]   
end


def update_user_by_id id, username, email
    query = %{
        UPDATE users
        SET username = $1, email = $2
        WHERE id = $3;
    }
    run_sql query, [username, email, id]
end


def update_score_by_id score, score_id
    query = "UPDATE scores SET score = $1 WHERE id = $2;"
    run_sql query, [score, score_id]   
end


def update_all_scores params
    params.each do |score_id, new_score|
        unless score_id == "_method" || score_id == "round_id"
            update_score_by_id new_score, score_id
        end
    end
end


def add_total_score_to_round round_id
    total_score_front_9 = %{
        SELECT SUM(s.score) AS front_9_total
          FROM scores AS s
          LEFT JOIN holes AS h
            ON s.hole_id = h.id
         WHERE s.round_id = $1
           AND h.number BETWEEN 1 AND 9;
    }
    front_9_score = run_sql total_score_front_9, [round_id]
    front_9_query = "UPDATE rounds SET front_9_total_score = $1 WHERE id = $2"
    run_sql front_9_query, [front_9_score[0]['front_9_total'], round_id]

    total_score_back_9 = %{
        SELECT SUM(s.score) AS back_9_total
          FROM scores AS s
          LEFT JOIN holes AS h
            ON s.hole_id = h.id
         WHERE s.round_id = $1
           AND h.number BETWEEN 10 AND 18;
    }
    back_9_score = run_sql total_score_back_9, [round_id]
    back_9_query = "UPDATE rounds SET back_9_total_score = $1 WHERE id = $2"
    run_sql back_9_query, [back_9_score[0]['back_9_total'], round_id]

    total_score_query = "SELECT SUM(score) as total FROM scores WHERE round_id = $1"
    total_score = run_sql total_score_query, [round_id]
    total_query = "UPDATE rounds SET total_score = $1 WHERE id = $2"
    run_sql total_query, [total_score[0]['total'], round_id]
end


def avg_total_score_by_user_id id
    query = %{
        SELECT ROUND(AVG(total_score))  AS avg_total_score
          FROM rounds
         WHERE user_id = $1;       
    }
    result = run_sql query, [id]
    result.first
end


def min_total_score_by_user_id id
    query = %{
        SELECT MIN(total_score)  AS min_total_score
          FROM rounds
         WHERE user_id = $1;       
    }
    result = run_sql query, [id]
    result.first
end


def avg_total_score_per_course_by_user_id id
    query = %{
        SELECT c.name AS course_name,
               ROUND(AVG(r.total_score)) AS avg_total_score
          FROM rounds AS r
          LEFT JOIN courses AS c
            ON r.course_id = c.id
         WHERE r.user_id = $1
         GROUP BY course_name;      
    }
    run_sql query, [id]
end   


def avg_score_per_hole_par_by_user_id id
    query = %{
        SELECT h.par,
               ROUND(AVG(s.score)) AS avg_score
          FROM rounds AS r
          LEFT JOIN scores AS s
            ON r.id = s.round_id
          LEFT JOIN holes AS h
            ON s.hole_id = h.id
         WHERE r.user_id = $1
         GROUP BY h.par
         ORDER BY h.par;    
    }
    run_sql query, [id]
end  


def calculate_front_and_back_course_par course_id
    front_9_query = %{
        SELECT SUM(h.par) AS front_9_par
          FROM courses AS c
          LEFT JOIN holes AS h
            ON c.id = h.course_id
         WHERE c.id = $1
           AND h.number BETWEEN 1 AND 9;       
    }
    front_9_par_result = run_sql front_9_query, [course_id]
    front_9_par = front_9_par_result.first['front_9_par']
    run_sql "UPDATE courses SET front_9_par = $1 WHERE id = $2", [front_9_par, course_id]

    back_9_query = %{
        SELECT SUM(h.par) AS back_9_par
          FROM courses AS c
          LEFT JOIN holes AS h
            ON c.id = h.course_id
         WHERE c.id = $1
           AND h.number BETWEEN 10 AND 18;
    }
    back_9_par_result = run_sql back_9_query, [course_id]
    back_9_par = back_9_par_result.first['back_9_par']
    run_sql "UPDATE courses SET back_9_par = $1 WHERE id = $2", [back_9_par, course_id]
end