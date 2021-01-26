class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :terminate, :destroy]
  before_action :check_login
  authorize_resource

  def index
    if current_user.role? :admin
      @current_assignments = Assignment.current.chronological.paginate(page: params[:curr_page]).per_page(10)
      @past_assignments = Assignment.past.chronological.paginate(page: params[:past_page]).per_page(10)
    elsif current_user.role? :manager
      @store = current_user.current_assignment.store
      @assignments = Assignment.for_store(@store).current.chronological.paginate(page: params[:curr_page]).per_page(10)
    else
      @assignments = Assignment.for_employee(current_user).current.chronological.paginate(page: params[:curr_page]).per_page(10)
    end
  end

  def show
    dates = DateRange.new(@assignment.start_date, @assignment.end_date)
    @past_shifts = Shift.past.for_employee(@assignment.employee).for_dates(dates).reverse_order.paginate(page: params[:past_page]).per_page(10)
    @upcoming_shifts = Shift.upcoming.for_employee(@assignment.employee).for_dates(dates).chronological.paginate(page: params[:upcoming_page]).per_page(10)
  end

  def new
    @assignment = Assignment.new
    @assignment.employee_id = params[:employee_id] unless params[:employee_id].nil?
    @assignment.store_id = params[:store_id] unless params[:store_id].nil?
    @assignment.pay_grade_id = params[:pay_grade_id] unless params[:pay_grade_id].nil?
    @assignment.start_date = Date.current.strftime("%b %d, %Y")
  end

  def edit
  end

  def create
    @assignment = Assignment.new(assignment_params)
    if @assignment.save
      redirect_to @assignment, notice: "Successfully added the assignment."
    else
      render action: 'new'
    end
  end

  def update
    if @assignment.update_attributes(assignment_params)
      redirect_to @assignment, notice: "Updated assignment information for #{@assignment.employee.proper_name}."
    else
      render action: 'edit'
    end
  end

  def terminate
    if @assignment.terminate
      redirect_to assignments_path, notice: "Assignment for #{@assignment.employee.proper_name} terminated."
    end
  end

  def destroy
    if @assignment.destroy
      redirect_to assignments_url, notice: "Successfully removed assignment for #{@assignment.employee.proper_name}."
    else
      render action: 'show'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def assignment_params
    params.require(:assignment).permit(:store_id, :employee_id, :pay_grade_id, :start_date)
  end

end
