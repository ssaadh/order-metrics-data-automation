# require 'watir-webdriver'
require 'watir'
require 'nokogiri'

module Watir
  class Element
    # Can list all attributes for most elements - so far, not iframes
    def list_attributes
      attributes = browser.execute_script( %Q[
        var s = {};
        var attrs = arguments[ 0 ].attributes;
        for ( var l = 0; l < attrs.length; ++l ) {
          var a = attrs[ l ]; s[ a.name ] = a.value;
        } ;
        return s; ], 
        self )
        
        attributes[ 'text' ] = text
        attributes[ :text ] = attributes[ 'text' ]
        attributes
    end
  end
  
  class IFrame < HTMLElement
    def list_attributes
      attributes = []
      @noko = Nokogiri::HTML( browser.html )
      noko_iframe_og = @noko
      
      noko_iframe = noko_iframe_og.css( 'iframe' )[ @selector[ :index ] ]
      
      noko_iframe.attributes.each { | attr_name, attr_value |
        attr_value.content = attr_value.content[ 0..750 ] if attr_value.content.length > 750
        attributes << { attr_name => attr_value.content }
      }      
      attributes = attributes.inject( &:merge )
      
      attributes
    end
    
    def list_selector
      @selector
    end
    
    def list_selector_index
      @selector[ :index ]
    end
  end
end
