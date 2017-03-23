class Admin::SubscriptionPlansController < AdminController 
  before_action :set_admin_subscription_plan, only: [:show, :edit, :update, :destroy]

  # GET /admin/subscription_plans
  # GET /admin/subscription_plans.json
  def index
    @admin_subscription_plans = SubscriptionPlan.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_subscription_plans }
    end
  end

  # GET /admin/subscription_plans/1
  # GET /admin/subscription_plans/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_subscription_plan }
    end
  end

  # GET /admin/subscription_plans/new
  def new
    @admin_subscription_plan = SubscriptionPlan.new
  end

  # POST /admin/subscription_plans
  # POST /admin/subscription_plans.json
  def create
    @admin_subscription_plan = SubscriptionPlan.new(admin_subscription_plan_params)

    respond_to do |format|
      if @admin_subscription_plan.save
        format.html { redirect_to [:admin, @admin_subscription_plan], notice: 'Subscription plan was successfully created.' }
        format.json { render json: @admin_subscription_plan, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @admin_subscription_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/subscription_plans/1
  # PATCH/PUT /admin/subscription_plans/1.json
  def update
    respond_to do |format|
      if @admin_subscription_plan.update(admin_subscription_plan_params)
        format.html { redirect_to [:admin, @admin_subscription_plan], notice: 'Subscription plan was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @admin_subscription_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/subscription_plans/1
  # DELETE /admin/subscription_plans/1.json
  def destroy
    @admin_subscription_plan.destroy
    respond_to do |format|
      format.html { redirect_to admin_subscription_plans_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_subscription_plan
      @admin_subscription_plan = SubscriptionPlan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_subscription_plan_params
      params.require(:subscription_plan).permit(:value, :agent_value, :agent_limit, :api_limit, :label, :comment)
    end
end
