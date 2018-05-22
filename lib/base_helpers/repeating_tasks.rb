class RepeatingProcesses
  # Example of one line of the output:
  # 3281  2-21:30:21 /usr/sbin/cron -f
  def initial_process_list_command
    "ps -u #{ ENV[ 'current_user' ] } -eo pid,etime,command"
  end
  
  # matching something like 2-20:47:39. That part.
  
  # 1. [[0-9]-]? - the optional beginning number and dash. Signifying days
  def egrep_regex_beginning
    '([0-9]-)?'
  end
  
  # Colon and seconds - They don't matter. Just here to make sure the regex is for sure getting the correct area.
  def egrep_regex_seconds
    ':[0-9]{2}'
  end
    
  # 2. ([0-9][2-9]|[1-9][0-9]): - the core important part.
  # The hours numbers
  # The | in between the numbers is for either being 2 hours or more or 10 hours or more. Need this "or" to keep 1 hour out.
  def egrep_regex_2_hours
    "#{ egrep_regex_beginning }([0-9][2-9]|[1-9][0-9]):[0-9]{2}#{ egrep_regex_seconds }"
  end
  
  # this pegs 1 hour 30 minutes as the lowest amt
  def egrep_regex_1_and_half_hour
    "#{ egrep_regex_beginning }([0-9][1-9]):[3-9][0-9]#{ egrep_regex_seconds }"
  end
  
  def egrep_all
    "#{ egrep_regex_beginning }([0-9][0-9]:)?[0-9][0-9]#{ egrep_regex_seconds }"
  end
  
  def grep_process( arg )
    "grep #{ arg }"
  end
  
  def grep_xvfb
    grep_process( 'Xvfb' )
  end
  
  def grep_chrome
    grep_process( 'chrome' )
  end
  
  def grep_v_bash
    grep_process( '-v bash' )
  end
  
  def awk_process
    "awk '{print $1}'"
  end
  
  def kill_command
    'xargs -I{} kill -9 {}'
  end
  
  # ps -u user -eo pid,etime,command | egrep ' ([0-9]+-)?([0-9]{2}:?){3}' | grep chrome | grep -v bash | awk '{print $1}' | xargs -I{} kill -9 {}
  def kill_zombie_chrome
    system( "#{ initial_process_list_command } | egrep '#{ egrep_regex_2_hours }' | #{ grep_chrome } | #{ grep_v_bash } | #{ awk_process } | #{ kill_command }" )
    system( "#{ initial_process_list_command } | egrep '#{ egrep_regex_1_and_half_hour }' | #{ grep_chrome } | #{ grep_v_bash } | #{ awk_process } | #{ kill_command }" )
  end
  
  # ps -u user -eo pid,etime,command | egrep ' ([0-9]+-)?([0-9]{2}:?){3}' | grep xvfb | grep -v bash | awk '{print $1}' | xargs -I{} kill -9 {}
  def kill_zombie_xvfb
    system( "#{ initial_process_list_command } | egrep '#{ egrep_regex_2_hours }' | #{ grep_xvfb } | #{ grep_v_bash } | #{ awk_process } | #{ kill_command }" )
    system( "#{ initial_process_list_command } | egrep '#{ egrep_regex_1_and_half_hour }' | #{ grep_xvfb } | #{ grep_v_bash } | #{ awk_process } | #{ kill_command }" )
  end
  
  def view_zombie_chrome
    system( "#{ initial_process_list_command } | egrep '#{ egrep_regex_2_hours }' | #{ grep_chrome } | #{ grep_v_bash }" )
    system( "#{ initial_process_list_command } | egrep '#{ egrep_regex_1_and_half_hour }' | #{ grep_chrome } | #{ grep_v_bash }" )
  end
  
  def view_zombie_xvfb
    system( "#{ initial_process_list_command } | egrep '#{ egrep_regex_2_hours }' | #{ grep_xvfb } | #{ grep_v_bash }" )
    system( "#{ initial_process_list_command } | egrep '#{ egrep_regex_1_and_half_hour }' | #{ grep_xvfb } | #{ grep_v_bash }" )
  end
  
  def view_chrome
    system( "#{ initial_process_list_command } | egrep '#{ egrep_all }' | #{ grep_chrome } | #{ grep_v_bash }" )
  end
  
  def view_xvfb
    system( "#{ initial_process_list_command } | egrep '#{ egrep_all }' | #{ grep_xvfb } | #{ grep_v_bash }" )
  end
  
  def kill_any_and_all_zombies
    system( "kill -9 $(ps -A -ostat,ppid | awk '/[zZ]/{print $2}')" )
  end
end

class RepeatingTasks
  def file_path
    @file_path ||= "#{ Rails.root }/check_fb.file"
  end
  
  ##
  # Touch/access file
  ##
  
  def file_exists?
    File.file?( file_path )
  end
  
  # returns file_path
  def touch_file
    FileUtils.touch file_path
  end
  
  # returns Time object
  def file_access_time
    access_time = nil
    File.open( file_path, 'r' ) do | f | 
      access_time = f.atime
    end
    
    access_time
  end
  
  # returns integer in seconds
  def elapsed_file_access_time
    Time.now - file_access_time
  end
  
  # If at least 10 min has elapsed
  def too_much_elapsed?
    ten_minutes_elapsed?
  end
  
  # If at least 10 min has elapsed
  def ten_minutes_elapsed?
    10 * 60 < elapsed_file_access_time
  end
  
  def delete_file
    File.delete( file_path )
  end
  
  
  ##
  # Modifying file
  ##
  
  def change_file
    File.open( file_path, 'w' ) do | f | 
      f << 'yo'
    end
  end
  
  def file_modification_time
    modification_time = nil
    File.open( file_path, 'r' ) do | f | 
      modification_time = f.mtime
    end
    
    modification_time
  end
  
  def elapsed_file_modification_time
    Time.now - file_modification_time
  end
end

class RepeatingTasksYt < RepeatingTasks  
  def file_path
    @file_path ||= "#{ Rails.root }/check_yt.file"
  end  
end
