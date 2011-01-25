require 'fraggel'

class LiveTest < Test::Unit::TestCase
  def start(timeout=1, &blk)
    EM.run do
      if timeout > 0
        EM.add_timer(timeout) { fail "Test timeout!" }
      end

      blk.call(Fraggel.connect)
    end
  end

  def stop
    EM.stop
  end

  def test_get
    start do |c|
      c.get "/ping" do |e|
        assert e.ok?, e.err_detail
        assert e.cas > 0
        assert_equal "pong", e.value
        stop
      end
    end
  end

  def test_set
    start do |c|
      c.set "/test-set", "a", :clobber do |ea|
        assert ea.ok?, ea.err_detail
        assert ea.cas > 0
        assert_nil ea.value

        c.get "/test-set" do |eb|
          assert eb.ok?, eb.err_detail
          assert_equal "a", eb.value
          stop
        end
      end
    end
  end

  def test_del
    start do |c|
      c.set "/test-del", "a", :clobber do |e|
        assert e.ok?, e.err_detail

        c.del("/test-del", e.cas) do |de|
          assert de.ok?, de.err_detail
          stop
        end
      end
    end
  end

  def test_error
    start do |c|
      c.set "/test-error", "a", :clobber do |ea|
        assert ! ea.mismatch?
        assert ea.ok?, ea.err_detail
        c.set "/test-error", "b", :missing do |eb|
          assert eb.mismatch?, eb.err_detail
          stop
        end
      end
    end
  end

  def test_watch
    start do |c|
      count = 0
      c.watch("/**") do |e|
        assert e.ok?, e.err_detail

        count += 1
        if count == 9
          stop
        end
      end

      10.times do
        EM.next_tick { c.set("/test-watch", "something", :clobber) }
      end
    end
  end

  def test_snap
    start do |c|
      c.set "/test-snap", "a", :clobber do |e|
        assert e.ok?, e.err_detail

        c.snap do |se|
          assert se.ok?, se.err_detail
          assert_not_equal 0, se.id

          c.set "/test-snap", "b", :clobber do |e|
            assert e.ok?, e.err_detail

            c.get "/test-snap", se.id do |ge|
              assert ge.ok?, ge.err_detail
              assert_equal "a", ge.value
              stop
            end
          end
        end
      end
    end
  end

  # TODO:  ???  Shouldn't a deleted snapid produce an error on read?
  def test_delsnap
    start do |c|
      c.snap do |se|
        assert se.ok?, se.err_detail
        assert_not_equal 0, se.id


        c.delsnap se.id do |de|
          assert de.ok?, de.err_detail

          c.get "/ping", se.id do |ge|
            assert ! ge.ok?, ge.err_detail
            stop
          end
        end
      end
    end
  end

  def test_noop
    start do |c|
      c.noop do |e|
        assert e.ok?, e.err_detail
        stop
      end
    end
  end

  def test_cancel
    start do |c|
      tag = c.watch("/test-cancel") do |e, done|
        p [e, done]

        if ! done
          assert e.ok?, e.err_detail
        end

        if done
          stop
        end

        c.cancel(tag)
      end

      c.set("/test-cancel", "a", :clobber)
    end
  end

  def test_walk
    start do |c|

      exp = [
        ["/test-walk/1", "a"],
        ["/test-walk/2", "b"],
        ["/test-walk/3", "c"]
      ]

      n = exp.length

      exp.each do |path, val|
        c.set path, val, :clobber do |e|
          assert e.ok?, e.err_detail
          n -= 1

          if n == 0
            p [:inif]
            items = []
            c.walk "/test-walk/*" do |e, done|
              p [:walk, e, done]
              if done
                assert_equal exp, items
                stop
              else
                items << [e.path, e.value]
              end
            end
          end
        end
      end

    end
  end

end
