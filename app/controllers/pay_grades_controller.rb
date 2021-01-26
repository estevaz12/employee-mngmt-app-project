class PayGradesController < ApplicationController
  before_action :set_pay_grade, only: [:edit, :update]
  before_action :check_login
  authorize_resource

  def index
    @active_pay_grades = PayGrade.active.alphabetical.paginate(page: params[:active_page]).per_page(10)
    @inactive_pay_grades = PayGrade.inactive.alphabetical.paginate(page: params[:inactive_page]).per_page(10)
    get_pay_rates
    puts @pay_grade_rates
  end

  def new
    @pay_grade = PayGrade.new
  end

  def edit
  end

  def create
    @pay_grade = PayGrade.new(pay_grade_params)
    if @pay_grade.save
      redirect_to pay_grades_path, notice: "Successfully added #{@pay_grade.level} pay grade."
    else
      render action: 'new'
    end
  end

  def update
    if @pay_grade.update_attributes(pay_grade_params)
      redirect_to pay_grades_path, notice: "Updated information for #{@pay_grade.level} pay grade."
    else
      render action: 'edit'
    end
  end

  private
  def get_pay_rates
    pay_grades = PayGrade.active.alphabetical + PayGrade.inactive.alphabetical
    rates = []
    for pg in pay_grades
      rates << pg.pay_grade_rates.chronological.reverse_order
    end

    @pay_grade_rates = []
    for list in rates
      for r in list
        @pay_grade_rates << r
      end
    end 
    @pay_grade_rates = @pay_grade_rates.paginate(page: params[:rates_page], per_page: 10)
  end

  def set_pay_grade
    @pay_grade = PayGrade.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def pay_grade_params
    params.require(:pay_grade).permit(:level, :active)
  end
end
