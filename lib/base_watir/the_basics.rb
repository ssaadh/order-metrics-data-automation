class TheBasics
  attr_accessor :headless, :browser, :device, :driver, :site, :html_file, :doc
  attr_accessor :location_info, :proxy, :user_agent
  
  attr_reader :latest_main_user_agent
  
  # Instantiate the parser on load as it's quite expensive - as the gem says
  USER_AGENT_PARSER = UserAgentParser::Parser.new

  def self.user_agent_parser
    USER_AGENT_PARSER
  end
  
  def self.latest_static_main_user_agent
    $latest_chrome_browser_ua
  end
  
  def latest_main_user_agent
    $latest_chrome_browser_ua
  end

  
  # @TODO Refactor, make this better
  # def method_missing( method_name, *arguments, &block )
  #   # @TODO rofl how do you do the arguments thing?
  #   @browser.method_name( *arguments )
  # end
  
  
  # Uh going with using opts. So the only thing so far is possibly having stuff_location, lol.
  def initialize( browser = :firefox, headless = nil, user_agent = {}, location_info = {}, opts = {} )
    # Does this work lol?
    @options = opts
    
    # So the the_location and device should be objects. Because their models will be from the db and be hashes right
    #location_info and device_info either have to be ActiveRecord models or Hashie objects for now. At least this make it not reliant on Rails. As it shouldn't be tied to any framework
    
    @headless = headless
    
    options[ :browser ] ||= browser
    #options[ :agent ] ||= device    
    
    # proxy
    # SKIP is a special own created data point to purposefully not use
    #if ( location_info.respond_to?( :details ) && location_info.details == 'SKIP' ) || location_info.blank?
      #@location_info = nil
    #else
      @location_info = location_info
    #end
    @proxy = @location_info
    
    # user agent
    @user_agent = user_agent
    # backup in case
    @the_user_agent = @user_agent
    
    # otherwise default landscape, see what that would be
    # This can be in opts hash as test?
    #options[ :orientation ] ||= :portrait
    
    ##
    
    initial_browser_setup
    
    internal_location_setup( location_info )
        
    device_setup_result = internal_device_setup( user_agent )
    
    #
    @browser = finalize_browser_setup
    
    # Have the browser viewport be smaller like a phone
    # @browser has to already be made
    #self.initial_resize_command
    #if device_setup_result != false
    #  internal_resizing_based_on_device( user_agent )
    #else
      # initial_resize_command_mobile
    #end
    
    # this isn't legit code. will just have width height in database soon
    
    # initial_resize_command_mobile if !user_agent.blank?
    resize( 1200, 1000 )# if user_agent.blank?
    #resize( 1200, 1280 ) if user_agent.blank?
  end
  
  #private
  def options
    @options ||= {}
  end
  
  ## Set up initial brower stuff
  def initial_browser_setup
    case options[ :browser ]
    when :firefox
      options[ :profile ] ||= Selenium::WebDriver::Firefox::Profile.new
    when :chrome
      options[ :switches ] ||= []
    when :phantomjs
    when :youtubejs
      
      user_agent = latest_main_user_agent
      @capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs( "phantomjs.page.settings.userAgent" => user_agent )    
    else
      raise 'Only :firefox and :chrome for now.'
    end
  end
  
  def finalize_browser_setup
    case options[ :browser ]
    when :firefox
      @browser = Watir::Browser.new :firefox, profile: options[ :profile ]
    when :chrome
      options[ :switches ] << '--disable-notifications'
      options[ :switches ] << '--disable-web-notification-custom-layouts'
      options[ :switches ] << '--allow-silent-push'
      @browser = Watir::Browser.new :chrome, switches: options[ :switches ]
    when :phantomjs
      @browser = Watir::Browser.new :phantomjs
    when :youtubejs
      require 'watir-webdriver'
      driver = Selenium::WebDriver.for :phantomjs, :desired_capabilities => @capabilities
      @browser = Watir::Browser.new driver
    else
      raise 'Only :firefox and :chrome for now.'
    end
  end
  
  
  ## Location Setup
  
  def location_setup( address = nil, port = '8080', type = :https )
    if address.blank? || address == 'SKIP' || address == 'skip'
      return 'no address breh - @TODO should test proxy'
    end
    
    case options[ :browser ]
    
    when :firefox
      if type == :https
        options[ :profile ][ :proxy ] = Selenium::WebDriver::Proxy.new ssl: "#{ address }:#{ port }"
      elsif type == :http
        options[ :profile ][ :proxy ] = Selenium::WebDriver::Proxy.new http: "#{ address }:#{ port }"
      end
      
    when :chrome
      if ( type == :https && type == :http )
        options[ :switches ] << "--proxy-server=#{ address }:#{ port }"
      elsif ( type == :socks ) || ( type == :socks5 )
        options[ :switches ] << "--proxy-server=socks://#{ address }:#{ port }"
        # options[ :switches ] << "--proxy-server=socks5://#{ address }:#{ port }"
      end
    when :phantomjs
      # @TODO set up proxy arguments for phantomjs
    when :youtubejs
    else
      raise 'Only :firefox and :chrome for now.'
    end
  end
  
  # MAKE THIS PRIVATE - makes the initial_lcation_setup method for already pre-ready object-like variables/objects
  def internal_location_setup( location_info )
    if ( location_info.class == Hashie::Mash ) || ( location_info.class == Proxy )
      
      if location_info.class == Hashie::Mash
        location_info.ip ||= 'localhost' # or 127.0.0.1?
        location_info.port ||= 8080
        location_info.type ||= 'socks5' #or socks
        
      elsif location_info.class == Proxy
        # a [database] model class
        if location_info.ip == 'SKIP' || location_info.ip == 'skip'
          return location_setup( nil )
        end
      end
      
      return location_setup( location_info.ip, location_info.port, location_info.type )
      
    else
      return 'no special location for this session, pal'
    end
  end
  

  ## Device Setup
  
  def device_setup( device_user_agent_string = nil )
    if ( device_user_agent_string.blank? )
      return 'no device user agent info string breh - @TODO should confirm device user agent info in some way'
    end
    
    case options[ :browser ]
    when :firefox
      options[ :profile ][ 'general.useragent.override' ] = device_user_agent_string
    when :chrome
      options[ :switches ] << "--user-agent=#{ device_user_agent_string }"
    when :phantomjs
      # @TODO get the code to do phantomjs. i think phantomjs has to be done in one go, so will prob need to change the code logic initially for phantomjs
    when :youtubejs
    else    
      raise 'Only :firefox and :chrome for now.'
    end
  end
  
  # MAKE THIS PRIVATE - makes the initial_lcation_setup method for already pre-ready object-like variables/objects
  def internal_device_setup( device_info )
    default_user_agent_string = 'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25'
    default_user_agent_string_4 = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5'
    # 320 x 480
    default_user_agent_string_6 = 'Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4'
    # 375 x 667
    
    # hoping this is a decent, and new/current testing user agent
    # as of early 2018
    def_mobile_current_user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1'
    
    def_desktop_current_user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36'
    def_desktop_current_user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36'
    
    if ( device_info.class == Hashie::Mash ) || ( device_info.class == TheUserAgent )
      
      if device_info.class == Hashie::Mash
        user_agent_string = default_user_agent_string
        
      elsif device_info.class == TheUserAgent
        # a [database] model class
        user_agent_string = device_info.unparsed
      end
      
      return device_setup( user_agent_string )
      
    else
      device_setup( def_desktop_current_user_agent )
      return false
      #return 'no special device for this session, pal'
    end
  end
  
  # This one doesn't matter for the Chrome of Firefox webdrivers
  def internal_resizing_based_on_device( device_info )
    if ( device_info.width.is_a? Integer ) && ( device_info.height.is_a? Integer )
      
      if ( device_info.orientation == :landscape ) || ( device_info.orientation == :portrait )
      # Confirming orientation is correct
        if ( device_info.width.to_f / device_info.height.to_f <= 0.75 ) && ( device_info.orientation == :portrait )
          # next # continue
        else
          'orientation and width/height are not correct with one another'
        end
      
      elsif device_info.type = :desktop
        # next #continue
      else
        # raise
        return 'orientation is incorrect and/or not correct type'
      end
    else
      # raise
      return 'width and height are not integers'
    end
    
    # This far means any issues were passed
    resize( device_info.width, device_info.height )
    # returns the width and height of the browser so can be sure they were modified properly
    pause 1
    return width, height
  end
  
  
  ## Quick shit
  
  def time_stamp
    Time.now.strftime( '%Y-%m-%d_%H-%M-%S' )
  end
  
  def scroll( x = 0, y = 20 )
    @browser.execute_script( "window.scrollTo( #{ x }, #{ y } );" )
  end
  
  def scroll_to_top
    @browser.execute_script( 'window.scrollTo(0, 0);' )
  end
  
  def scroll_to_bottom
    @browser.execute_script( 'window.scrollTo(0, document.body.scrollHeight);' )
  end
  
  def scroll_to_element( element )
    @browser.execute_script( 'arguments[0].scrollIntoView();', element )
  end
  
  def width_not_working
    @browser.execute_script( 'return screen.width;' )
  end
  
  def height_not_working
    @browser.execute_script( 'return screen.height;' )
  end
  
  def width
    @browser.execute_script( 'return window.innerWidth' )
  end
  
  def height
    @browser.execute_script( 'return window.innerHeight' )
  end
  
  # includes toolbars, statusbar, etc
  def outer_width
    @browser.execute_script( 'return window.outerWidth' )
  end
  
  # includes toolbars, statusbar, etc
  def outer_height
    @browser.execute_script( 'return window.outerHeight' )
  end
  
  def initial_resize_command_mobile( width = nil, height = nil )    
    # Open another browser window that can be of any width and height. Not constrained by Chrome on certain OSes, etc
    @browser.execute_script "( function() { window.open( document.URL, '','width=#{ width },height= #{ height }' ); } ) ();"
    
    # Close the initial browser window now that the better one is open    
    @browser.window( index: 0 ).close
    
    resize( width, height )
  end
  
  def resize( width = nil, height = nil)
    # @TODO later this will have to be a case or some sort of way to have different width height at the very least for iphone, small or big android, ipad mini/ipad, android tablet, desktop
    width = 320 if width.nil?
    height = 460 if height.nil?
    
    # And do what you would normally have done with the original window, with this new one, proceed breh
    @browser.driver.manage.window.resize_to( width, height )
    @browser.driver.manage.window.move_to( 0,0 )
    
    # Can use JS too
    #@browser.execute_script( 'window.resizeTo( width, height )' )
    #@browser.execute_script( 'window.moveTo( 0,0 )' )
  end
  
  
  ##
  # Wrappers for Watir [Webdriver]
  ##
  
  def noko
    Nokogiri::HTML( @browser.html )
  end
  
  def favicon_url( nokogiri_obj = nil )
    nokogiri_obj = noko if nokogiri_obj.blank?
    
    nokogiri_obj.at_css( 'link[rel="shortcut icon"]' )[ 'href' ]
  end
  
  def go_to_url( url )
    return nil if url.blank?
    
    counter = 0
    
    Rails.logger.loop.info "go to url: #{ url }"
    begin
      @browser.goto url
    rescue Net::ReadTimeout => e
      Raven.capture_exception( e )
      
      Rails.logger.loop.info "go to url: #{ e } typical error."
      counter += 1
      
      if counter == 3
        @browser.execute_script( 'window.stop()' )        
        Rails.logger.loop.info "go to url: stopping (window.stop). 3 tries."
      end
      
      if counter < 3
        Rails.logger.loop.info "go to url: re-trying"
        retry
      end
    rescue => e
      Raven.capture_exception( e )
      Rails.logger.loop.info "go to url: rescue retry. error: #{ e }"
      counter += 1
      
      if counter == 3
        @browser.execute_script( 'window.stop()' )        
        Rails.logger.loop.info "go to url: stopping (window.stop). 3 tries."
      end
      
      if counter < 3
        Rails.logger.loop.info "go to url: re-trying"
        retry
      end
    end
    
    sleep( 2 )
    
    Rails.logger.loop.info "go to url: END"
    true
  end
  
  # Uh shit
  
  def save_entire_screenshot( index = 0 )
    location = "#{ current_set_fs_location }/#{ self.time_stamp }.png"
    @browser.screenshot.save location
    
    return location
  end
  
  # @TODO not DRY with the other html save method
  def save_entire_html( index = 0 )
    location = "#{ current_set_fs_location }/#{ self.time_stamp }.html"
    File.open( location, 'w') { | file | file.write @browser.html }
    
    return @html_file = location
  end
  
  # @TODO is this possible?
  def save_specific_screenshot( watir_resource, index = 0 )
    
  end
  
  # Requires watir browser element
  def save_particular_html( watir_resource, index = 0 )
    location = "#{ current_set_fs_location }/#{ self.time_stamp }_#{ watir_resource.tag_name }.html"
    File.open( location, 'w') { | file | file.write watir_resource.html }
    
    return @current_particular_html_file = location
  end
  
  
  ## Scraped resources saved locations
  
  # @TODO Should be getter setter even if temp
  def stuff_location
    @options[ :stuff_location ]
  end
  
  def current_set_fs_location
    # Organize the file structure for scraped things like screenshots/html source by year/month under the domain folder
    month = Time.now.strftime( '%m' )
    location = "#{ crawled_site_fs_location }/#{ Time.now.year }/#{ month }"
    
    # Create the folder for the current month if it isn't created, along with all the nested parent folders as needed
    FileUtils::mkdir_p location unless File.exist? location
    
    return location
  end
  
  def crawled_site_fs_location( id = nil )
    # id = @crawled_site.id if id.nil?
    "#{ @options[ :stuff_location ] }/crawled/#{ just_basic_url }"
  end
  
  # Get any subdomain[s], domain, and extension. To be sure you are viewing the right place
  def just_basic_url( url = nil )
    # url = self.url if url.nil?
    url = @browser.url if url.nil?
    
    #safety precaution - would have to be in a model as well prob anyway
    return Domainatrix.parse( url.strip ).host
  end
  
  
  # ad crawling
  
  ## THIS WILL BE SPUN OFF INTO OWN CLASS BREH
end
