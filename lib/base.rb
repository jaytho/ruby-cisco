require 'ostruct'

module Cisco
  
  class Group < OpenStruct
    def to_a
      @table.inject([]) {|result, pair| result << pair.last; result }
    end
  end
  
  class Base < Cisco
    
    attr_reader :info, :ints
    
    # This is meant to be redefined in subclasses to send initial commands like 'terminal length 0' upon connecting.
    def extra_init
    end

    def confmode
      enable unless enabled?
      cmd("configure terminal")
      @confmode = true
    end
    
    def confmode?
      return @confmode
    end

  end
  
end