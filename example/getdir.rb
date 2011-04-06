require 'rubygems'
require 'eventmachine'
require 'fraggle'

EM.run do

  EM.error_handler do |e|
    $stderr.puts e.message + "\n" + (e.backtrace * "\n")
  end

  c = Fraggle.connect
  c.level = Fraggle::Logger::INFO

  ents = []
  req = c.getdir(nil, "/doozer") do |e|
    ents << e.path
  end

  req.error do
    puts *ents
  end


end
