module Cisco
  
  
  class C2900 < Cisco
    
    def extra_init
      cmd("terminal length 0")
      refresh_info
    end
    
    def refresh_info
      @hw = DetailSet.new
      @sw = DetailSet.new
      data = cmd("sh ver").split("\n")
      @sw.ios = data[2]
      @sw.compile = data[4]
      @sw.rom = data[7]
      @sw.update = data[9]
      @sw.return = data[10]
      @sw.image = data[11]
      @sw.freeze
      
      @hw.device = data[14]
      @hw.procid = data[15]
      @hw.reboot = data[16]
      
    end

  end

end