class Admin::OrdersController < AdminController
  def index
    @orders = Order.all
  end

  def show
    @order = Order.find_by_id(params[:id])
    if @order.present?
      render 'show'
    else
      flash[:danger] = "Order_id [#{params[:id]}] Not Found"
      redirect_to admin_orders_path
    end
  end
end
