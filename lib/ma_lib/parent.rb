module MA
  class Parent
    def initialize( wrap )
      @wrap = wrap
      @browser = wrap.browser
    end
    
    def profit_analysis_link_element
      @browser.a( visible_text: 'Profit Analysis' )
    end
  end
end
