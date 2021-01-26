class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  before_action :check_login
  authorize_resource

  def index
    if current_user.role? :admin
      admins = Employee.admins.active.alphabetical
      managers = Employee.managers.active.alphabetical
      regulars = Employee.regulars.active.alphabetical
      @active_employees = (admins+managers+regulars).paginate(page: params[:emp_page], per_page: 10)
      @inactive_employees = Employee.inactive.alphabetical.paginate(page: params[:inac_emp_page]).per_page(10)
    else
      # For managers
      get_managers_employees
    end
  end

  def show
    retrieve_employee_data
  end

  def new
    @employee = Employee.new
    @employee.first_name = params[:first_name] unless params[:first_name].nil?
    @employee.last_name = params[:last_name] unless params[:last_name].nil?
    @employee.role = params[:role] unless params[:role].nil?
  end

  def edit
    @employee.role = "employee" if current_user.role?(:employee)
    @employee.role = "manager" if current_user.role?(:manager)
  end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to @employee, notice: "Successfully added #{@employee.proper_name} as an employee."
    else
      render action: 'new'
    end
  end

  def update
    if @employee.update_attributes(employee_params)
      redirect_to @employee, notice: "Updated #{@employee.proper_name}'s information."
    else
      render action: 'edit'
    end
  end

  def destroy
    if @employee.destroy
      redirect_to employees_url, notice: "Successfully removed #{@employee.proper_name} from the system."
    else
      @employee.errors.add(:base, 'Employee cannot be deleted because of previously worked shifts, but status has been set to inactive.')
      retrieve_employee_data
      render action: 'show'
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_employee
    @employee = Employee.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :ssn, :phone, :date_of_birth, :role, :active, :username, :password, :password_confirmation)
  end

  def retrieve_employee_data
    @current_assignment = @employee.current_assignment
    @previous_assignments = @employee.assignments.past.chronological.paginate(page: params[:assgn_page]).per_page(5)
    @past_shifts = @employee.shifts.for_past_days(7).chronological.reverse_order.paginate(page: params[:pshifts_page]).per_page(5)
    @upcoming_shifts = @employee.shifts.for_next_days(7).chronological
    @missed_shifts = []
    unless @employee.current_assignment.nil?
      @missed_shifts = @employee.current_assignment.shifts.past.pending.chronological.reverse_order
    end
  end

  def get_managers_employees
    @store = current_user.current_assignment.store
    my_employees = Assignment.for_store(@store).current.map(&:employee_id)
    managers = []
    regulars = []
    for id in my_employees
      e = Employee.find(id)
      if e.role? :manager
        managers << e
      else
        regulars << e
      end
    end
    managers = managers.sort_by {|e| e.name}
    regulars = regulars.sort_by {|e| e.name}
    @my_employees = (managers+regulars).paginate(page: params[:emp_page], per_page: 10)
  end
end
