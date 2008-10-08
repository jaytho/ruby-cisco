require 'ostruct'

module Cisco
  
  class DetailSet < OpenStruct
  end
  
  class Cisco < Base
    
    attr_reader :hw, :sw, :ints
    
    
    
  end
  
end