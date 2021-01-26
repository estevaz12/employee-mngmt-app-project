Rails.application.routes.draw do

  # Semi-static page routes
  get 'home', to: 'home#index', as: :home
  get 'home/about', to: 'home#about', as: :about
  get 'home/contact', to: 'home#contact', as: :contact
  get 'home/privacy', to: 'home#privacy', as: :privacy
  get 'home/search', to: 'home#search', as: :search
  get 'home/:shift_id', to: 'home#index', as: :home_manager

  # Authentication routes
  resources :sessions
  resources :employees
  get 'users/new', to: 'employees#new', as: :signup
  get 'user/edit', to: 'employees#edit', as: :edit_current_user
  get 'login', to: 'sessions#new', as: :login
  get 'logout', to: 'sessions#destroy', as: :logout

  # Resource routes (maps HTTP verbs to controller actions automatically):
  resources :stores
  resources :assignments
  resources :shifts
  resources :jobs
  resources :shift_jobs
  resources :pay_grades
  resources :pay_grade_rates

  # Custom routes
  patch 'assignments/:id/terminate', to: 'assignments#terminate', as: :terminate_assignment

  get 'payrolls', to: 'payrolls#index', as: :payrolls
  get 'payrolls/new/employee/', to: 'payrolls#new_employee', as: :new_employee_payroll
  get 'payrolls/new/store', to: 'payrolls#new_store', as: :new_store_payroll
  get 'payrolls/employee', to: 'payrolls#create_employee', as: :employee_payroll
  get 'payrolls/store', to: 'payrolls#create_store', as: :store_payroll
  get 'payrolls/:id/employee/', to: 'payrolls#show_employee', as: :show_employee_payroll
  get 'payrolls/:id/store/', to: 'payrolls#show_store', as: :show_store_payroll

  patch 'shifts/:id/clock_in', to: 'shifts#clock_in', as: :start_shift
  patch 'shifts/:id/clock_out', to: 'shifts#clock_out', as: :end_shift

  # You can have the root of your site routed with 'root'
  root 'home#index'
end
