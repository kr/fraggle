require 'rubygems'
require 'eventmachine'
require 'fraggle'

EM.run do

  EM.error_handler do |e|
    $stderr.puts e.message + "\n" + (e.backtrace * "\n")
  end

  c = Fraggle.connect "doozer:?ca=127.0.0.1:8041"

  c.watch "/example/*" do |e|
    p e
  end

  EM.add_periodic_timer(0.5) do
    c.set "/example/#{rand(10)}", "test", :clobber
  end

end
