class Setup
  attr_reader :headless, :wrap, :browser
  attr_reader :base_logger
  
  def initialize
    @base_logger = Rails.logger.loop
  end
  
  def use_profile
    profile_location = "#{ Rails.root }/browser/profile"
    switches = %W[--user-data-dir=#{profile_location}]

    prefs = {
      :download => {
        prompt_for_download: false,
        default_directory: '/opt/srv/oma/downloads'
      }
    }
    
    switches << '--disable-notifications'
    switches << '--disable-web-notification-custom-layouts'
    switches << '--allow-silent-push'
    
    # switches << "--user-agent=#{ device_user_agent_string }"
    
    return prefs, switches
  end
  
  def headless_pref_switches( display_number = nil )
    display_number = rand( 100..999 ) if display_number.nil?
    
    @base_logger.info 'BEGIN - Setup - headless_pref_switches'
    
    $headless = nil
    if GeneralHelpers.host_os == :linux
      unless display_number.nil?
        $headless = Headless.new( display: display_number )
        $headless.start
      end
    end
    
    prefs, switches = use_profile
    @browser = Watir::Browser.new :chrome, :prefs => prefs, switches: switches
    
    @wrap = TheBasics.new( :chrome, $headless, {}, {}, {}, @browser )
    
    @base_logger.info 'END - Setup - headless_pref_switches'    
    return $headless, @wrap
  end
  alias :default :headless_pref_switches
end
