class UsersController < ApplicationController
  before_action :require_reguser, except: [:new, :create]

  def new
    @user = User.new
  end

  def show
    @user = current_user
  end

  def edit
    @user = current_user
    @address = current_user.addresses.last
  end

  def create
    @user = User.new(user_params)
    @address = Address.new(
                          street: params[:street],
                          city: params[:city],
                          state: params[:state],
                          zip_code: params[:zip_code],
                          nickname: "home"
                        )
    # @address = Address.new(address_params)

    if @user.save
      @address.user_id = @user.id
      @address.save
      session[:user_id] = @user.id
      flash[:success] = "Registration Successful! You are now logged in."
      redirect_to profile_path
    else
      flash.now[:danger] = @user.errors.full_messages
      @user.update(email: "", password: "")
      render :new
    end
  end

  def update
    @user = current_user
    @address = Address.new(update_address_params)
    @user.update(user_update_params)
    if @user.save
      @address.user_id = @user.id
      @address.save
      flash[:success] = "Your profile has been updated"
      redirect_to profile_path
    else
      flash.now[:danger] = @user.errors.full_messages
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_update_params
    uup = user_params
    uup.delete(:password) if uup[:password].empty?
    uup.delete(:password_confirmation) if uup[:password_confirmation].empty?
    uup
  end

  def update_address_params
    params.require(:address).permit(:street, :city, :state, :zip_code)
  end
end
