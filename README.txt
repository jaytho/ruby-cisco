Ruby-Cisco
==========
This tool aims to provide transport-agnostic functionality similar to Perl's 
Net::Telnet::Cisco module, for easy communication with Cisco devices. In addition, 
I would like to provide subclasses to retrieve, present and set configuration 
parameters in an OO fashion.

I will be implementing both Telnet and SSH support.

As I begin here, I know little of the differences between various Cisco 
devices and their configuration parameters. At first, I will be writing a 
class for Catalyst 2900 series switches, since they are something I have
to deal with regularly.

I have borrowed a couple of ideas from Martin Boese's ciscotelnet.rb for
the groundwork. It can be found here http://www.ruby-forum.com/topic/135280

This README will be updated as I move along. This is my first foray into
writing solid, reusable, (and publicly examined) code, so please bear with me. 
Anyone wanting to help is more than welcome - just send me an email or hit 
me up on IRC.

jakecdouglas@gmail.com
yakischloba on Freenode
