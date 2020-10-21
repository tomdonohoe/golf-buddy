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