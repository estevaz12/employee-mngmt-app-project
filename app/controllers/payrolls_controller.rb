class PayrollsController < ApplicationController
  before_action :check_login
  authorize_resource

  def index
  end

  def show_store
    @store = Store.find(params[:id])
    @start_date = params[:start_date].to_date unless params[:start_date].nil?
    @end_date = params[:end_date].to_date unless params[:end_date].nil?
    generate_payroll_info(@store, @start_date, @end_date)
  end

  def show_employee
    @employee = Employee.find(params[:id])
    if current_user.role? :admin
      @start_date = params[:start_date].to_date unless params[:start_date].nil?
      @end_date = params[:end_date].to_date unless params[:end_date].nil?
    else
      @start_date = 1.week.ago.to_date
      @end_date = Date.current
    end
    generate_payroll_info(@employee, @start_date, @end_date)
  end

  def new_store
    @store = Store.find(params[:store_id]) unless params[:store_id].nil?
  end

  def new_employee
    @employee = Employee.find(params[:employee_id]) unless params[:employee_id].nil?
  end

  def create_store
    @store = params[:store_id]

    # So admin dashboard doesn't crash
    if !params[:start_date].nil?
      handle_date_inputs
    else
      @start_date = eval(params[:quantity]+'.'+params[:date_range]+'.ago').to_s
      @end_date = Date.current.to_s
    end

    if @store.empty?
      redirect_to new_store_payroll_path, alert: 'Please select a store.'
    elsif @start_date.empty? && @end_date.empty?
      redirect_to new_store_payroll_path, alert: 'Please provide a date.'
    else
      @store = Store.find(params[:store_id])
      redirect_to show_store_payroll_path(@store.id, start_date: @start_date, end_date: @end_date),
      notice: "Successfully generated payroll report for #{@store.name}."
    end
  end

  def create_employee
    @employee = params[:employee_id]
    handle_date_inputs

    if @employee.empty?
      redirect_to new_employee_payroll_path, alert: 'Please select an employee.'
    elsif @start_date.empty? && @end_date.empty?
      redirect_to new_employee_payroll_path, alert: 'Please provide a date.'
    else
      @employee = Employee.find(params[:employee_id])
      redirect_to show_employee_payroll_path(@employee.id, start_date: @start_date, end_date: @end_date),
      notice: "Successfully generated pay report for #{@employee.name}."
    end
  end

  private
  def generate_payroll_info(obj, start_date, end_date)
    handle_dates(start_date, end_date)
    @calculator = PayrollCalculator.new(@date_range)
    if obj.is_a?(Employee)
      @payroll_report = @calculator.create_payroll_record_for(obj)
      @worked_shifts = obj.shifts.for_dates(@date_range).chronological.paginate(page: params[:page]).per_page(5)
    else
      @payroll_report = @calculator.create_payrolls_for(obj)
      @paginated_report = @payroll_report.paginate(page: params[:page], per_page: 5)
    end
  end

  def handle_dates(start_date, end_date)
    if start_date.nil?
      @date_range = DateRange.new(end_date)
    elsif end_date.nil?
      @date_range = DateRange.new(start_date)
    else
      @date_range = DateRange.new(start_date, end_date)
    end
  end

  def handle_date_inputs
    q_empty = params[:quantity].empty?
    s_date_not_empty = !params[:quantity].empty? && !params[:start_date].empty?
    e_date_not_current = params[:end_date].to_date != Date.current

    if q_empty || s_date_not_empty || e_date_not_current
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    else
      @start_date = eval(params[:quantity]+'.'+params[:date_range]+'.ago').to_s
      @end_date = Date.current.to_s
    end
  end
end
