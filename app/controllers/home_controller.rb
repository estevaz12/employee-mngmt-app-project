class HomeController < ApplicationController
  def index
    if logged_in?
      if current_user.role? :admin
        @stores = Store.active.alphabetical.paginate(page: params[:page]).per_page(5)
      elsif current_user.role? :manager
        get_remaining_shifts
        @store = current_user.current_assignment.store
        @todays_shifts = Shift.for_store(@store).for_next_days(0).chronological.paginate(page: params[:ts_page]).per_page(8)
        get_finished_shifts
        get_shift_job_info unless params[:shift_id].nil?
        @upcoming_shifts = Shift.for_store(@store).for_next_days(7).chronological.paginate(page: params[:us_page]).per_page(10)
        @past_shifts = Shift.for_store(@store).for_past_days(7).chronological.reverse_order.paginate(page: params[:ps_page]).per_page(10)
      else
        @upcoming_shifts = Shift.for_employee(current_user).for_next_days(7).chronological
        @past_shifts = Shift.for_employee(current_user).for_past_days(7).chronological.reverse_order
        get_remaining_shifts
      end
    end
  end

  def about
  end

  def contact
  end

  def privacy
  end

  def search
    redirect_back(fallback_location: home_path) if params[:query].blank?
    @query = params[:query]
    @employees = Employee.search(@query).alphabetical
    if current_user.role? :manager
      get_employees_in_my_store
    end
    @total_hits = @employees.size
    if @total_hits == 1
      redirect_to employee_path(@employees.first),
                  notice: "Redirect to #{@employees.first.proper_name}'s page because there was only 1 result."
    end
  end

  private
  def get_employees_in_my_store
    store = current_user.current_assignment.store
    new_list = []
    for e in @employees
      new_list << e if !e.current_assignment.nil? && e.current_assignment.store == store
    end
    @employees = new_list
  end

  def get_remaining_shifts
    @past_shifts = Shift.for_employee(current_user).for_past_days(7).chronological.reverse_order
    time = Time.local(2000,1,1, Time.now.hour, Time.now.min, 0)
    todays_shifts = Shift.for_employee(current_user).for_next_days(0)
    todays_finished_shifts = todays_shifts.finished
    todays_missed_shifts = todays_shifts.pending.where('end_time < ?', time)
    @remaining_shifts = todays_shifts - todays_finished_shifts - todays_missed_shifts
    @remaining_shifts = @remaining_shifts.sort_by { |s| [s.date, s.start_time]  }
  end

  def get_finished_shifts
    todays_shifts = Shift.for_employee(current_user).for_next_days(0)
    todays_finished_shifts = todays_shifts.finished.reverse_order
    @finished_shifts = todays_finished_shifts + Shift.for_store(@store).for_past_days(7).finished.chronological.reverse_order
    @finished_shifts = @finished_shifts.paginate(page: params[:fs_page], per_page: 5)
  end

  def get_shift_job_info
    @shift = Shift.find(params[:shift_id])
    @jobs = Job.active.alphabetical
  end
end
