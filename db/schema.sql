CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username TEXT,
    email TEXT,
    password_digest TEXT
);

-- user_id 1, name = 'tom' password = 'pudding'
-- user_id 2, name = 'fatty' password = 'cake'

CREATE TABLE rounds (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    course_id INTEGER,
    created_at DATE,
    total_score INTEGER
);

CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name TEXT,
    par INTEGER,
    num_holes INTEGER
);

CREATE TABLE holes (
    id SERIAL PRIMARY KEY,
    course_id INTEGER,
    number INTEGER,
    par INTEGER
);

CREATE TABLE scores (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    round_id INTEGER,
    hole_id INTEGER,
    score INTEGER
);


CREATE TABLE friends (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    friend_id INTEGER
);

CREATE TABLE posts (
     id SERIAL PRIMARY KEY,
     user_id INTEGER,
     round_id INTEGER
);

CREATE OR REPLACE FUNCTION multiple_users_ids(VARIADIC int[])
RETURNS TABLE (user_id int, round_id int, username text, round_date date, course_name text, course_par int, total_score int) AS
$func$
SELECT p.user_id,
        p.round_id,
        u.username,
        r.created_at AS round_date,
        c.name AS course_name,
        c.par AS course_par,
        r.total_score AS user_total_score
  FROM posts AS p
  LEFT JOIN users AS u
    ON p.user_id = u.id
  LEFT JOIN rounds AS r
    ON p.round_id = r.id
  LEFT JOIN courses AS c
    ON r.course_id = c.id
  WHERE p.user_id = ANY($1);
$func$ LANGUAGE sql;



SELECT p.user_id,
        p.round_id,
        u.username,
        r.created_at AS round_date,
        c.name AS course_name,
        c.par AS course_par,
        r.total_score AS user_total_score
  FROM posts AS p
  LEFT JOIN users AS u
    ON p.user_id = u.id
  LEFT JOIN rounds AS r
    ON p.round_id = r.id
  LEFT JOIN courses AS c
    ON r.course_id = c.id
  WHERE user_id = $1;

SELECT p.user_id,
       p.round_id,
       u.username,
       r.created_at AS round_date,
       c.name AS course_name,
       c.par AS course_par,
       r.total_score AS user_total_score
  FROM posts AS p
  LEFT JOIN users AS u
    ON p.user_id = u.id
  LEFT JOIN rounds AS r
    ON p.round_id = r.id
  LEFT JOIN courses AS c
    ON r.course_id = c.id

