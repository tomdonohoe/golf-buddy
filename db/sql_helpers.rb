require 'pg'
require_relative '../utils/auth.rb'

def run_sql query, params = []
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'golf_buddy'})
    result = db.exec_params query, params
    db.close
    result
end


def create_new_user username, email, password_digest
    query = "INSERT INTO users (username, email, password_digest) VALUES ($1, $2, $3);"
    run_sql query, [username, email, password_digest]
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