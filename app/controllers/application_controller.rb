class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  #before_filter :check_user_for_page

  protected

  def check_session_user
    if session[:user_id]
      begin
        @session_user = User.find session[:user_id]
      rescue ActiveRecord::RecordNotFound
        session[:user_id] = nil
      end
    end
  end

  def get_or_create_session_user
    if session[:user_id]
      @session_user = User.find session[:user_id]
    else
      @session_user = User.create! name: 'Köter'
      @session_user.name = "#{@session_user.name}#{@session_user.id}"
      @session_user.save!
      session[:user_id] = @session_user.id
    end
  end

end
