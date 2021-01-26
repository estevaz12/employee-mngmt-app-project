class PayGradeRatesController < ApplicationController
  before_action :check_login
  authorize_resource

  def index
    redirect_to pay_grades_path
  end

  def new
    @pay_grade_rate = PayGradeRate.new
    @pay_grade_rate.pay_grade_id = params[:pay_grade_id] unless params[:pay_grade_id].nil?
  end

  def create
    @pay_grade_rate = PayGradeRate.new(pay_grade_rate_params)
    if @pay_grade_rate.save
      redirect_to pay_grades_path, notice: "Successfully added pay rate for the #{@pay_grade_rate.pay_grade.level} pay grade."
    else
      render action: 'new'
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def pay_grade_rate_params
    params.require(:pay_grade_rate).permit(:pay_grade_id, :rate, :start_date, :end_date)
  end
end
