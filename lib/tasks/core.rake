namespace :core do
  require_relative '../base_helpers/repeating_tasks.rb'
  
	desc 'Routine basic task'
	task :run => :environment do
    Rails.logger.routine_tasks.info 'BEGIN run'
    active_jerb = Run.new
    active_jerb.go
    Rails.logger.routine_tasks.info 'END run'
	end
  
	desc 'Test'
	task :run_test => :environment do
    Rails.logger.routine_tasks.info 'BEGIN run_test'
    active_jerb = Run.new
    Pry::Rescue {
      active_jerb.go
    }
    Rails.logger.routine_tasks.info 'END run_test'
	end
end
