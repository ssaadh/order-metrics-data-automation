namespace :main_app do
  require_relative '../base_helpers/repeating_tasks.rb'
  
  ##
  #
  ##
  
  desc 'Kills any zombie old Chrome processes. 1.5 hours or older.'
  task :kill_zombie_chrome => :environment do    
    RepeatingProcesses.new.kill_zombie_chrome
    Rails.logger.routine_tasks.info 'did kill_zombie_chrome'
  end
  
  desc 'Kills any zombie old xvfb processes. 1.5 hours or older.'
  task :kill_zombie_xvfb => :environment do
    RepeatingProcesses.new.kill_zombie_xvfb
    Rails.logger.routine_tasks.info 'did kill_zombie_xvfb'
  end
  
  desc 'View the pids for zombie Chrome processes, 1.5 hours or older (2 commands)'
  task :view_zombie_chrome => :environment do
    RepeatingProcesses.new.view_zombie_chrome
  end
  
  desc 'View the pids for zombie xvfb processes, 1.5 hours or older (2 commands)'
  task :view_zombie_xvfb => :environment do
    RepeatingProcesses.new.view_zombie_xvfb
  end
  
  desc 'As task says'
  task :kill_any_and_all_zombies do
    RepeatingProcesses.new.kill_any_and_all_zombies
  end
  
  
  ##
  #
  ##
  
  'View all chrome processes'
  task :view_chrome => :environment do
    RepeatingProcesses.new.view_chrome
  end
  
  'View all xvfb processes'
  task :view_xvfb => :environment do
    RepeatingProcesses.new.view_xvfb
  end
end
