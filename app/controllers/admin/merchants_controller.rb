class Admin::MerchantsController < Admin::BaseController
  def show
    @merchant = User.find(params[:id])
    if @merchant.role == "merchant"
      render :'/dashboard/dashboard/index'
    else
      redirect_to admin_user_path(@merchant)
    end
  end

  def enable
    set_user_active(true)
  end

  def disable
    set_user_active(false)
  end

  def downgrade
    @merchant = User.find(params[:id])
    @merchant.role = 'default'
    @merchant.save
    redirect_to admin_user_path(@merchant)
  end

  private

  def set_user_active(state)
    user = User.find(params[:id])
    user.active = state
    user.save
    redirect_to merchants_path
  end
end
