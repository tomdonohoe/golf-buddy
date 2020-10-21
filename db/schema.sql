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