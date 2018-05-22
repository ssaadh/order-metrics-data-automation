# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# examples (--help for more)
# wheneverize .
# whenever --update-crontab

set :output, 'log/cron_log.log'

##
# Main app stuff
##

# Irregular times - separated by two hours
every '1 1,3,5,7,9,22 * * *' do
  rake 'core:run'
end

# try to get the last one for the day. 3 min before midnight for ample time to do everything
# @TODO reduce to 2 min if can be sure 3 min is more than enough.
every '57 23 * * *' do
  rake 'core:run'
end

# 10 am to 9 pm, hourly
every '1 10,11,12,13,14,15,16,17,18,19,20,21 * * *' do
  rake 'core:run'
end


##
# Process managing
##

# Once an hour, 2 minutes before xvfb
every '4 * * * *' do
  rake 'main_app:kill_zombie_chrome'
end

# Once an hour, 2 minutes after chrome
every '6 * * * *' do
  rake 'main_app:kill_zombie_xvfb'
end

# Once every 6 hours, 2 minutes after both
# every '5 1,7,13,19 * * *' do
# Once every 4 hours, 2 minutes after both
every '8 1,5,9,13,17,21 * * *' do
  rake 'main_app:kill_any_and_all_zombies'
end
