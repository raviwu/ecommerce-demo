class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    # If the user exists AND the password entered is correct.
    if user && user.authenticate(params[:password])
      # Save the user id inside the browser cookie. This is how we keep the user
      # logged in when they navigate around our website.
      session[:user_id] = user.id
      @current_user = user
      redirect_to root_path
      flash[:success] = "Login Successfully."
    else
      # If user's login doesn't work, send them back to the login form.
      flash[:danger] = "Wrong password / email combination."
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
    flash[:success] = "Logout Successfully."
  end
end
