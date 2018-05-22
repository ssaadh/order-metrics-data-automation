class Login < Parent
  def initialize( wrap )
    super( wrap )
    @lib = MA::Login.new( wrap )
  end
  
  def login    
    # @TODO should load and check cookie working first
    
    login_directly
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
  
  def shopify_subdomain
    'fomosupplyco'
  end
end
