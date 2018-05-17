# require 'watir-webdriver'
require 'watir'

# credit to p0deje
module Watir
  class Element
    DOM_WAIT_JS = File.read( "#{ File.dirname( __FILE__ ) }/monkeypatch_watir-wait-for-dom.js" ).freeze

    #
    # Returns true if DOM is changed within the element.
    #
    # @example Wait until DOM is changed inside element with default delay
    #   browser.div(id: 'test').wait_until(&:dom_changed?).click
    #
    # @example Wait until DOM is changed inside element with default delay
    #   browser.div(id: 'test').wait_until do |element|
    #     element.dom_changed?(delay: 5)
    #   end
    #
    # @param delay [Integer, Float] how long to wait for DOM modifications to start
    #
    
    # credit to p0deje - reasoning for update:    
    # Since Watir 6.4, we need to wrap element interaction with #element_call
    # to make sure element is relocated once it goes stale. Otherwise, we end
    # up with infinite loop rescuing stale element error and retrying.
        
    def dom_changed?( delay: 1.1 )
      element_call do
        begin
          driver.manage.timeouts.script_timeout = delay + 1
          driver.execute_async_script( DOM_WAIT_JS, wd, delay )
        rescue Selenium::WebDriver::Error::JavascriptError => error
          # sometimes we start script execution before new page is loaded and
          # in rare cases ChromeDriver throws this error, we just swallow it and retry
          retry if error.message.include?( 'document unloaded while waiting for result' )
          raise
        ensure
          # TODO: make sure we rollback to user-defined timeout
          # blocked by https://github.com/seleniumhq/selenium-google-code-issue-archive/issues/6608
          driver.manage.timeouts.script_timeout = 1
        end
      end # element_call
    end
  end # Element
end
