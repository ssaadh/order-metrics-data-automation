class Login < Parent
  def initialize( wrap )
    super( wrap )
    @lib = MA::Login.new( wrap )
  end
  
  def login
    @wrap.go_to_url( @lib.app_url )
    if !File.read( cookie_file ).blank_zero?
      cookies_load
    end
    
    result = @wrap.go_to_url( @lib.app_url )
    
    # didn't login
    if @browser.url.match( 'login' )    
      result = login_directly
      cookies_save
    end
    
    result
  end
  
  def login_directly
    @wrap.go_to_url( @lib.initial_url )
    @lib.login_page_wait
    
    @lib.log_in_with_shopify_button_element.click
    @lib.shopify_store_name_popover_wait
    
    @lib.enter_shopify_store_name_field_element.set( shopify_subdomain )
    @lib.enter_shopify_store_name_connect_button_element.click
    
    @lib.shopify_login_page_wait
    @lib.shopify_login_email_element.set( Rails.application.credentials.shopify_user )
    @lib.shopify_login_password_element.set( Rails.application.credentials.shopify_pass )
    @lib.shopify_login_button_element.click
    
    @lib.logged_in?    
  end
  
  def cookies_save( file = nil )
    file = cookie_file if file.nil?
    @browser.cookies.save( file )
  end
  
  def cookies_load( file = nil )
    file = cookie_file if file.nil?
    @browser.cookies.load( file )
    sleep 1
    @browser.refresh
  end
  
  def cookie_file
    "#{ Rails.root }/cookie_file.txt"
  end
  
  def shopify_subdomain
    ENV[ 'shopify_subdoman' ]
  end
end
