require 'bcrypt'


def hash_password password
    BCrypt::Password.create(password)
end


def authenticate_password? db_password, user_entered_password
    db_stored_password = BCrypt::Password.new(db_password)
    db_stored_password == user_entered_password
end
