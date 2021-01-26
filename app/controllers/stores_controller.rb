class StoresController < ApplicationController

  before_action :set_store, only: [:show, :edit, :update]
  before_action :check_login
  authorize_resource

  def index
    # get data on all stores and paginate the output to 10 per page
    @active_stores = Store.active.alphabetical.paginate(page: params[:ac_stores_page]).per_page(10)
    @inactive_stores = Store.inactive.alphabetical.paginate(page: params[:inac_stores_page]).per_page(10)
  end

  def show
    @current_managers = Assignment.current.for_store(@store).for_role('manager').paginate(page: params[:emp_page]).per_page(5)
    @current_employees = Assignment.current.for_store(@store).by_employee.paginate(page: params[:emp_page]).per_page(5)
    @upcoming_shifts = Shift.for_store(@store).for_next_days(7).chronological.paginate(page: params[:ushifts_page]).per_page(5)
    get_missed_shifts
  end

  def new
    @store = Store.new
  end

  def edit
  end

  def create
    @store = Store.new(store_params)
    if @store.save
      redirect_to @store, notice: "Successfully added #{@store.name} to the system."
    else
      render action: 'new'
    end
  end

  def update
    if @store.update_attributes(store_params)
      redirect_to @store, notice: "Updated store information for #{@store.name}."
    else
      render action: 'edit'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_store
    @store = Store.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def store_params
    params.require(:store).permit(:name, :street, :city, :phone, :state, :zip, :active)
  end

  def get_missed_shifts
    current_assignments = Assignment.current.for_store(@store)
    @missed_shifts = []
    for a in current_assignments
      missed = a.shifts.past.pending
      if !missed.empty?
        for s in missed
          @missed_shifts << s
        end
      end
    end
    @missed_shifts = @missed_shifts.sort_by{ |s| [s.date, s.start_time]  }.reverse
    @missed_shifts = @missed_shifts.paginate(page: params[:mshifts_page], per_page: 5)
  end

end
