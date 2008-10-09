module Cisco
  
  
  class C2900 < Cisco
    
    def extra_init
      cmd("terminal length 0")
      refresh_info
    end
    
    def refresh_info
      @info = DetailSet.new
      data = cmd("sh ver").split("\n")
      @info.ios = data[2]
      @info.compile = data[4]
      @info.rom = data[7]
      @info.uptime = data[9]
      @info.return = data[10]
      @info.image = data[11]
      @info.device = data[14]
      @info.procid = data[15]
      @info.last_reset = data[16]
      @info.mem = data[23]
      @info.mac = data[24]
      @info.mobo_num = data[25]
      @info.ps_num = data[26]
      @info.mobo_serial = data[27]
      @info.ps_serial = data[28]
      @info.model_rev = data[29]
      @info.mobo_rev = data[30]
      @info.model = data[31]
      @info.serial = data[32]
      @info.confreg = data[33]
      @info.freeze
    end

  end

end