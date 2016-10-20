class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :impersonate]

  def index
    @users = User.includes({account: [:bundles, :agent_servers, :active_servers, :monitors, :check_api_calls]}, {billing_plan: [:subscription_plan]})

    @user_count = User.count
    @servers_count = AgentServer.count
    @recent_heartbeats = AgentServer.active.count
    @app_count = Bundle.via_agent.count
    @active_app_count = Bundle.via_active_agent.count
    @monitor_count = Bundle.via_api.count
    @total_revenue = @users.reduce([]) { |acc, u| acc << u.billing_plan if u.billing_plan; acc }.map(&:monthly_cost).reduce(&:+)
  end

  def new
    @user = User.new
  end

  def impersonate
    impersonate_user(@user)
    redirect_to dashboard_path, notice: "You are now #{@user.email}. Be careful!"
  end

  def show
    @billing_manager = BillingManager.new(@user)
    @billing_presenter = @billing_manager.to_presenter
    @all_plans = SubscriptionPlan.all
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if UserManager.sign_up(@user)
        format.html { redirect_to admin_root_path }
        # format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render :new }
        # format.json { render json: { attributes: @user.errors, full_messages: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if sub_ids = subscription_params[:available_subscriptions]
      @billing_manager = BillingManager.new(@user)
      @user = @billing_manager.set_available_subscriptions!(sub_ids)
    end

    if params[:user]
      @user.assign_attributes(user_params)
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_path, notice: 'User was successfully updated.' }
        # format.json { render json: @user, status: :ok, location: @user }
      else
        format.html { render :edit }
        # format.json { render json: { attributes: @user.errors, full_messages: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :onboarded)
  end

  def subscription_params
    params.permit(:available_subscriptions => [])
  end

end
