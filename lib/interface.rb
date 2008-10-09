module Cisco
  
  class Interface
    
    attr_reader :status, :stats, :mac
    
    # We pass a parent device into the constructor, as well as the text to parse out it's details.
    def initialize(parent, textary)
      raise CiscoError.new("Parent must be an instance of Cisco::Base.") unless parent.kind_of?(Cisco::Base)
      @parent = parent
      set_info(textary)
    end
    
    
    
    def refresh_info
      # do something here to pull relevant text from @parent
      set_info(textary)
    end
    
    private
    
    def set_info(textary)
      #parse out our details and set them on ourself
      textary.delete_at(0)
      @status = textary[1]
      @mac = textary[2].slice(/....\.....\...../)
    end
    
  end
  
end