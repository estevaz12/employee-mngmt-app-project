class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy, :clock_in, :clock_out]
  before_action :check_login
  authorize_resource

  def index
    if current_user.role? :admin
      @upcoming_shifts = Shift.upcoming.chronological.paginate(page: params[:upcoming_page]).per_page(10)
      @past_shifts = Shift.past.chronological.reverse_order.paginate(page: params[:past_page]).per_page(10)
    elsif current_user.role? :manager
      store = current_user.current_assignment.store
      @upcoming_shifts = Shift.for_store(store).upcoming.chronological.paginate(page: params[:upcoming_page]).per_page(10)
      @past_shifts = Shift.for_store(store).past.chronological.reverse_order.paginate(page: params[:past_page]).per_page(10)
    else
      @upcoming_shifts = Shift.for_employee(current_user).upcoming.chronological.paginate(page: params[:upcoming_page]).per_page(10)
      @past_shifts = Shift.for_employee(current_user).past.chronological.reverse_order.paginate(page: params[:past_page]).per_page(10)
    end
  end

  def show
    @employee = @shift.employee
    @store = @shift.store
    @jobs = Job.active.alphabetical
    @shift_jobs = @shift.shift_jobs
  end

  def new
    @shift = Shift.new
    @jobs = Job.active.alphabetical
    @shift.assignment_id = params[:assignment_id] unless params[:assignment_id].nil?
  end

  def edit
    @jobs = Job.active.alphabetical
  end

  def create
    @shift = Shift.new(shift_params)
    if @shift.save
      redirect_to @shift, notice: "Successfully added a shift for #{@shift.employee.proper_name}."
    else
      render action: 'new'
    end
  end

  def update
    if @shift.update_attributes(shift_params)
      redirect_to @shift, notice: "Updated shift information for #{@shift.employee.proper_name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    if @shift.destroy
      redirect_to shifts_url, notice: "Successfully removed shift for #{@shift.employee.proper_name}."
    else
      @employee = @shift.employee
      @store = @shift.store
      @jobs = Job.active.alphabetical
      @shift.errors.add(:base, "This shift either has begun or has finished and cannot be deleted.")
      render action: 'show'
    end
  end

  def clock_in
    time_clock = TimeClock.new(@shift)
    if Time.now.hour > @shift.end_time.hour
      redirect_to home_path, alert: 'This shift has already passed. You cannot clock in.'
    elsif Time.now.hour == @shift.end_time.hour && Time.now.min >= @shift.end_time.min
      redirect_to home_path, alert: 'This shift has already passed. You cannot clock in.'
    else
      time_clock.start_shift_at
      redirect_to home_path, notice: 'Successfully started the shift.'
    end
  end

  def clock_out
    time_clock = TimeClock.new(@shift)
    if @shift.status == 'pending'
      redirect_to home_path, alert: 'This shift has not been started yet.'
    else
      time_clock.end_shift_at
      redirect_to home_path, notice: 'Successfully ended the shift.'
    end
  end

  private
  def set_shift
    @shift = Shift.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shift_params
    params.require(:shift).permit(:assignment_id, :date, :start_time, :end_time, :status, :notes, :job_ids => [])
  end
end
