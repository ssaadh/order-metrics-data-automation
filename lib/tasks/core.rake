namespace :core do
  require_relative '../base_helpers/repeating_tasks.rb'
  
	desc 'Routine basic task'
	task :run => :environment do
    Rails.logger.routine_tasks.info 'BEGIN run'
    active_jerb = Run.new
    run.go
    Rails.logger.routine_tasks.info 'END run'
	end
  
	desc 'Test'
	task :run_test => :environment do
    Rails.logger.routine_tasks.info 'BEGIN run'
    active_jerb = Run.new
    run.go_test
    Rails.logger.routine_tasks.info 'END run'
	end
end
