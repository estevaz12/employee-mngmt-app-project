module ShiftsHelper

  def get_assignment_options
    Assignment.current.chronological.map{|a| ["#{a.employee.name}", a.id] }.sort
  end

  def get_assignment_options_manager
    store = current_user.current_assignment.store
    Assignment.for_store(store).current.chronological.map{|a| ["#{a.employee.name}", a.id] }.sort
  end
end
