require 'securerandom'

class PagesController < ApplicationController

  before_filter :load_page, only: [:show, :pick_user, :user_picked]

  def show
    unless (@user = get_session_user_for_page)
      redirect_to pick_user_url(@page.token)
      return
    end

    @title = { black: '', blue: '' }
  end

  def create
    page = Page.create! name: 'KöterTag To The Rescue!', token: SecureRandom.hex
    redirect_to page_url(page.token)
  end

  def pick_user
    get_available_users
    @user = User.new
  end

  def user_picked
    if params[:user_id].present?
      # existing user
      @user = User.find params[:user_id]
      once_again = true unless @user
    else
      # new user
      @user = User.new name: params[:user][:name], page: @page
      once_again = true unless @user.save
    end

    if once_again
      get_available_users
      render :pick_user
    else
      session["user-#{@page.id}"] = @user.id
      redirect_to page_url(@page.token)
    end
  end

  protected

  def load_page
    begin
      @page = Page.find_by_token params[:token]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Seite nicht gefunden :-('
      redirect_to root_url
      false
    end
  end

  def get_session_user_for_page
    return false unless (user_id = session["user-#{@page.id}"])

    begin
      User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end

  def get_available_users
    @available_users = User.where(page: @page).order(:name)
  end

end
