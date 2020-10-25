require_relative '../db/sql_helpers.rb'


def logged_in?
    if session['user_id']
        true
    else
        false
    end
end


def current_user_details
    find_user_by_id session['user_id']
end


def is_current_user_already_following? friend_id
    current_user_id = current_user_details['id']
    result = find_friends_by_id current_user_id, friend_id
    if result.count > 0
        true
    else
        false
    end
end


def get_all_posts_of_users_friends
    user = current_user_details
    friends_of_user = find_friend_ids_by_user_id user['id']
    friend_ids = []
    friends_of_user.each do |friend|
     friend_ids << friend['friend_id'].to_i
    end
    friend_ids_string = "{#{friend_ids.join(',')}}"
    find_all_posts_by_friend_ids friend_ids_string
end
