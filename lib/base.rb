require 'ostruct'

module Cisco
  
  class Group < OpenStruct
    def to_a
      @table.inject([]) {|result, pair| result << pair.last; result }
    end
  end
  
  class Base < Cisco
    
    attr_reader :info, :ints
    

  end
  
end