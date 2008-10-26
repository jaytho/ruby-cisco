module Cisco
  
  class Interface
    
    attr_reader :name, :status, :stats, :mac
    
    # We pass a parent device into the constructor, as well as the text to parse out it's details.
    def initialize(parent, name)
      raise CiscoError.new("Parent must be an instance of Cisco::Base.") unless parent.kind_of?(Cisco::Base)
      @parent = parent
      @name = name
      refresh
    end
    
    def refresh
      # do something here to pull relevant text from @parent
      set_info(text)
    end
    
    private
    
    def set_info(text)
      #parse out our details and set them on ourself
      @mac = text.slice(/....\.....\...../)
    end
    
  end
  
end