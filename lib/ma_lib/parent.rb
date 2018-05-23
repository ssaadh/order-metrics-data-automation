module MA
  class Parent
    def initialize( wrap )
      @wrap = wrap
      @browser = wrap.browser
    end
    
    def app_url
      'https://app.ordermetrics.io/#'
    end
    
    def profit_analysis_link_element
      @browser.a( visible_text: 'Profit Analysis' )
    end
  end
end
