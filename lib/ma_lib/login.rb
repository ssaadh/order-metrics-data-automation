module MA
  class Login < Parent    
    ## Variables
    
    def initial_url
      'https://app.ordermetrics.io/login'
    end
    
    def shopify_subdomain      
    end
    
    def shopify_login_url
      "https://#{ shopify_subdomain }.myshopify.com/admin/auth/login"
    end
    
    
    ## Order Metrics login
    
    def login_page_wait
      log_in_with_shopify_button_element.wait_until_present
    end
    
    def log_in_with_shopify_button_element
      @browser.div( id: 'signin-shopify' ).button
    end
    
    def enter_shopify_store_name_popover_element
      # @browser.div( class: 'modal-content', role: 'document' )
      @browser.div( class: 'modal-content' )
    end
    
    def shopify_store_name_popover_wait
      enter_shopify_store_name_popover_element.wait_until_present
    end
    
    def enter_shopify_store_name_field_element
      @browser.text_field( class: 'shopify-shopname-input' )
    end
    
    def enter_shopify_store_name_connect_button_element
      # @browser.button( class: 'shopify-connection-connect' )
      @browser.button( text: 'Connect' )
    end
    
    
    ## Shopify Login

    def shopify_login_page_wait
      shopify_login_email_element.wait_until_present
    end
    
    def shopify_login_page_loaded?
      shopify_login_email_element.exist_pres_vis?
    end
    
    def shopify_login_email_element
      @browser.text_field( id: 'Login' )
    end
    
    def shopify_login_password_element
      @browser.text_field( id: 'Password' )
    end
    
    def shopify_login_button_element
      # @browser.button( class: 'dialog-submit' )
      @browser.button( text: 'Log in' )
    end
    
    
    ## Verifying
    
    # check up to a few diff ways to see if logged in
    def logged_in?
      if !@browser.url.match( 'app.ordermetrics.io' )
        return false
      end
      
      profit_analysis_link_element.wait_until_present
      if !profit_analysis_link_element.exist_pres_vis?
        return false
      end
      
      true
    end
  end
end
