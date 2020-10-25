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
     username TEXT,
     round_date DATE,
     course_name TEXT,
     course_par INTEGER,
     user_total_score INTEGER
);

CREATE OR REPLACE FUNCTION multiple_users_ids(VARIADIC int[])
RETURNS TABLE (id int, user_id int, username text, round_date date, course_name text, course_par int, user_total_score int) AS
$func$
SELECT * FROM posts WHERE user_id = ANY($1);
$func$ LANGUAGE sql;



SELECT SUM(h.par) AS front_9_par
  FROM courses AS c
  LEFT JOIN holes AS h
    ON c.id = h.course_id
 WHERE c.id = 1
   AND h.number BETWEEN 1 AND 9;

SELECT SUM(h.par) AS back_9_par
  FROM courses AS c
  LEFT JOIN holes AS h
    ON c.id = h.course_id
 WHERE c.id = 1
   AND h.number BETWEEN 10 AND 18;