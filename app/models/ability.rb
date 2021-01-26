class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= Employee.new # guest user (not logged in)

    if user.role? :admin
      can :manage, :all

    elsif user.role? :manager
      can :manage, Shift
      can :clock_in, Shift
      can :clock_out, Shift
      can :manage, ShiftJob
      can :read, Job
      can :manage, Payroll

      can :index, Store

      can :show, Store do |this_store|
        curr_store = user.current_assignment.store_id
        curr_store == this_store.id
      end

      can :index, Assignment

      can :show, Assignment do |this_assignment|
        curr_store = user.current_assignment.store_id
        store = Store.find(curr_store)
        my_assignments = Assignment.for_employee(user).map(&:id)
        my_employees_assignments = Assignment.for_store(store).current.map(&:id) + my_assignments
        my_employees_assignments.include? this_assignment.id
      end

      can :index, Employee

      can :show, Employee do |this_employee|
        curr_store = user.current_assignment.store_id
        store = Store.find(curr_store)
        my_employees = Assignment.for_store(store).current.map(&:employee_id)
        my_employees.include? this_employee.id
      end

      can :edit, Employee do |e|
        curr_store = user.current_assignment.store_id
        store = Store.find(curr_store)
        my_employees = Assignment.for_store(store).current.map(&:employee_id)
        if (e.role? :manager) && (e.id != user.id)
          false
        else
          my_employees.include? e.id
        end
      end

      can :update, Employee do |e|
        curr_store = user.current_assignment.store_id
        store = Store.find(curr_store)
        my_employees = Assignment.for_store(store).current.map(&:employee_id)
        if (e.role? :manager) && (e.id != user.id)
          false
        else
          my_employees.include? e.id
        end
      end

    elsif user.role? :employee
      can :index, Assignment
      can :manage, Payroll
      can :read, Shift
      can :clock_in, Shift
      can :clock_out, Shift

      can :show, Assignment do |a|
        a.employee_id == user.id
      end

      can :show, Employee do |e|
        e.id == user.id
      end

      can :edit, Employee do |e|
        e.id == user.id
      end

      can :update, Employee do |e|
        e.id == user.id
      end

    else
    end
  end
end
