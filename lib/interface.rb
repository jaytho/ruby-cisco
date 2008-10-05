module Cisco
  
  class Interface
    
    # We pass a parent device into the constructor, as well as the text to parse out it's details.
    def initialize(parent, text)
      raise CiscoError.new("Parent must be an instance of Cisco::Cisco.") unless parent.kind_of?(Cisco)
      @parent = parent
      set_info(text)
    end
    
    
    
    def refresh_info
      # do something here to pull relevant text from @parent
      set_info(text)
    end
    
    private
    
    def set_info(text)
      #parse out our details and set them on ourself
    end
    
  end
  
end