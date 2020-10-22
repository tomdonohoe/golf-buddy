CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username TEXT,
    email TEXT,
    password_digest TEXT
);

-- user_id 1 password = 'pudding'
-- user_id 2 password = 'cake'
-- user_id 3 password = 'pie'
-- user_id 4 password = 'yogurt'
-- user_id 5 password = 'jane'


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