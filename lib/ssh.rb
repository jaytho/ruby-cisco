require 'rubygems'
require 'net/ssh'

module Cisco
  
  class SSH < Net::SSH
    
    def initialize(*args)
      super(*args)
      @chan = self.open_channel
      @chan.send_channel_request("shell")
      @chan.on_data {|ch, data| @buf << data}
    end
    
    def puts(data)
      @chan.send_data(data)
    end
    
    # Look at Telnet and IO's expect to see how this is done
    def expect(prompt)
      if @buf =~ prompt
        buf = @buf
        @buf = ""
        return buf
      end
    end
        
  end # class SSH

end # module Cisco