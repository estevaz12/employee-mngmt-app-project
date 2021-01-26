module StoresHelper

  def payroll(store, date_range)
    if date_range == 'two_week'
      calculator =  PayrollCalculator.new(DateRange.new(2.weeks.ago.to_date))
    else
      calculator =  PayrollCalculator.new(DateRange.new(store.assignments.chronological.last.start_date))
    end
    payroll =  calculator.create_payrolls_for(store)
    total_pay(payroll)
  end

  def total_pay(payroll)
    total_pay = 0
    for p in payroll
      total_pay += p.pay_earned
    end
    total_pay
  end

  def missed_shifts(store)
    missed = store.shifts.past.pending.count.to_f
    total = store.shifts.past.count
    ((missed / total) * 100).round(1)
  end

  def under_aged(store)
    count = 0
    for a in store.assignments.current
      emp = Employee.find(a.employee_id)
      if !emp.over_18?
        count += 1
      end
    end
    count
  end
end
