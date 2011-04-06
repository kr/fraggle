require 'rubygems'
require 'eventmachine'
require 'fraggle'

EM.run do

  EM.error_handler do |e|
    $stderr.puts e.message + "\n" + (e.backtrace * "\n")
  end

  c = Fraggle.connect

  paths = []
  req = c.walk(nil, "/**") do |e|
    paths << e.path+"="+e.value
  end

  req.done do
    puts *paths
  end


end
