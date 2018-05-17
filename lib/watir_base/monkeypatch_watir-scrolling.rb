require 'watir'

module Watir
  class Element
    def scroll_toward_top
      browser.execute_script( 'arguments[0].scrollIntoView();', self )
    end
    
    def scroll_toward_bottom
      browser.execute_script( 'arguments[0].scrollIntoView( false );', self )
    end
    
    def scroll_to_center
      script = <<-JAVASCRIPT
        var boundries = arguments[ 0 ].getBoundingClientRect();
        var head = boundries.top - ( window.innerHeight / 2 );
        var side = boundries.left - ( window.innerWidth / 2 );
        window.scrollTo( side, top );
      JAVASCRIPT
      
      browser.execute_script( script, self )
    end
  end # Element
end
