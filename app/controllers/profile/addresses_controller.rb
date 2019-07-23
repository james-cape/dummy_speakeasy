class Profile::AddressesController < ApplicationController

  def new
    @address = Address.new
  end

  def create
    @address = Address.new(address_params)
    @address.user_id = current_user.id
    @address.save
    flash[:success] = "You added a new address."
    redirect_to profile_path
  end

  def update
    @address = Address.find(params[:id])
    @address.update(address_params)

    flash[:success] = "Your Address has been updated!"

    redirect_to profile_path
  end

  def edit
    @address = Address.find(params[:id])
  end

  def destroy
    @user = current_user
    @user.addresses.delete(Address.find(params[:id]))
    redirect_to profile_path
  end

  private

    def address_params
      params.require(:address).permit(:nickname, :street, :city, :state, :zip_code)
    end
end
