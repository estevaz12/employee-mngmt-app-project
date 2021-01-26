module PayrollsHelper
  def total_pay(payroll)
    total_pay = 0
    for p in payroll
      total_pay += p.pay_earned
    end
    total_pay
  end

  def total_hours(payroll)
    total_hours = 0
    for p in payroll
      total_hours += p.hours
    end
    total_hours
  end

  DATE_RANGES = [['Days', 'days'], ['Weeks', 'weeks'], ['Months', 'months'], ['Years', 'years']]
end
