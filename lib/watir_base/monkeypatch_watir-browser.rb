require 'watir'

class Watir::Browser  
  # @TODO get some info on this method. point of it. example usage.
  def go_for_it( method )
    begin
      self.send( method.to_sym )
      return true
    rescue
      return false
    end
   end

   def is_open?
     return exists? if go_for_it( :exists? )
     
     # exists? doesn't work
     false     
   end
end

module Watir
  class Element
    def exist_pres?
      exists? && present?
    end
    
    def exist_pres_vis?
      begin
        # check exists and present first. They won't give an error. Visible shouldn't give an error if exists or present are false, so the error shouldn't ever come up. But just in case.
        if !exist_pres?
          return false
        end
        result = visible?
      rescue Watir::Exception::UnknownObjectException => e
        # @TODO should this still be false?
        return nil
      end
      
      # Initially I thought this would always be true, but the element can exist. Just not be visible.
      return result
    end
  end
end
