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


SELECT r.id AS round_id,
       r.created_at AS date,
       r.total_score,
       r.user_id,
       r.course_id,
       c.name AS course_name,
       c.par AS course_par,
       c.num_holes,
       h.number AS hole_number,
       h.par AS hole_par,
       s.score AS user_score
  FROM rounds AS r
  LEFT JOIN courses AS c
    ON r.course_id = c.id
  LEFT JOIN holes AS h
    ON c.id = h.course_id
  LEFT JOIN scores AS s
    ON s.round_id = r.id
   AND s.hole_id = h.id
 WHERE r.user_id = 1 and r.id = 1;


 -- Avg total score
SELECT ROUND(AVG(total_score))  AS avg_total_score
  FROM rounds
 WHERE user_id = 1;

 -- Avg score by course
SELECT c.name AS course_name,
       ROUND(AVG(r.total_score)) AS avg_total_score
  FROM rounds AS r
  LEFT JOIN courses AS c
    ON r.course_id = c.id
 WHERE r.user_id = 1
 GROUP BY course_name;

 -- Avg score by hole par
 SELECT h.par,
        ROUND(AVG(s.score)) AS avg_score
   FROM rounds AS r
   LEFT JOIN scores AS s
     ON r.id = s.round_id
   LEFT JOIN holes AS h
     ON s.hole_id = h.id
  WHERE r.user_id = 1
  GROUP BY h.par
  ORDER BY h.par;