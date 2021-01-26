class ShiftJobsController < ApplicationController
  before_action :check_login
  authorize_resource

  def new
    @shift_job = ShiftJob.new
    @shift = Shift.find(params[:shift_id])
    @employee = @shift.employee
  end

  def create
    @shift_job = ShiftJob.new(shift_job_params)
    if @shift_job.save
      redirect_to shift_path(@shift_job.shift),
                  notice: "Successfully added job(s) for #{@shift_job.shift.employee.proper_name}'s shift."
    else
      @shift = Shift.find(params[:shift_job][:shift_id])
      @employee = @shift.employee
      render action: 'new', locals: { shift: @shift, employee: @employee }
    end
  end

  def destroy
    @shift_job = ShiftJob.find(params[:id])
    @shift_job.destroy
    redirect_to shift_path(@shift_job.shift),
                notice: "Successfully removed #{@shift_job.job.name} for #{@shift_job.shift.employee.proper_name}'s shift."
  end

  private
    def shift_job_params
      params.require(:shift_job).permit(:shift_id, :job_id)
    end

end
