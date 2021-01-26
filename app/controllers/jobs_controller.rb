class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  before_action :check_login
  authorize_resource

  def index
    @active_jobs = Job.active.alphabetical.paginate(page: params[:active_page]).per_page(10)
    @inactive_jobs = Job.inactive.alphabetical.paginate(page: params[:inactive_page]).per_page(10)
  end

  def show
  end

  def new
    @job = Job.new
  end

  def edit
  end

  def create
    @job = Job.new(job_params)
    if @job.save
      redirect_to @job, notice: "Successfully added #{@job.name}."
    else
      render action: 'new'
    end
  end

  def update
    if @job.update_attributes(job_params)
      redirect_to @job, notice: "Updated job information for #{@job.name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    if @job.destroy
      redirect_to jobs_url, notice: "Successfully removed #{@job.name}."
    else
      @job.errors.add(:base, "This job has been worked before and cannot be deleted now.")
      render action: 'show'
    end
  end

  private
  def set_job
    @job = Job.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def job_params
    params.require(:job).permit(:name, :description, :active)
  end
end
