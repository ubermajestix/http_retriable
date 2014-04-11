require 'bundler/setup'
require 'http_retriable'
require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'
# require 'fakeweb'

class HttpRetriableTest < MiniTest::Spec
  before do
    Logger.any_instance.stubs(:info)
    HttpRetriable.any_instance.stubs(:sleep)
  end

  describe "exponential backoff mode" do
    it "should increment seconds_to_sleep exponentially during retry" do
      retriable = HttpRetriable.new
      assert retriable.backoff?, 'should backoff by default'
      assert_equal 2, retriable.seconds_to_sleep
      retriable.send(:retry!)
      retriable.send(:retry!)
      assert_equal 4, retriable.seconds_to_sleep
    end
  end

  describe "pure sleep mode" do
    it "should not increment seconds to sleep during retry" do
      retriable = HttpRetriable.new(:backoff => false)
      assert !retriable.backoff?, 'should not backoff'
      assert_equal 2, retriable.seconds_to_sleep
      retriable.send(:retry!)
      retriable.send(:retry!)
      assert_equal 2, retriable.seconds_to_sleep
    end
  end

  describe "quick retries" do
    it "should not retry if quick_retries set to 0" do
      retriable = HttpRetriable.new(:quick_retries => 0)
      assert_equal false, retriable.quick_retry?
    end

    it "should not retry if its tried too many times" do
      retriable = HttpRetriable.new(:quick_retries => 1)
      retriable.send(:quick_retry!)
      assert_equal false, retriable.quick_retry?
    end

    it "should not sleep" do
      retriable = HttpRetriable.new
      retriable.expects(:sleep).never
      retriable.send(:quick_retry!)
    end

    it "should keep track of quick_retries" do
      retriable = HttpRetriable.new
      assert_equal 0, retriable.quick_retried
      retriable.send(:quick_retry!)
      assert_equal 1, retriable.quick_retried
    end
  end

  describe "retries" do
    it "should sleep" do
      retriable = HttpRetriable.new
      retriable.expects(:sleep).with(2)
      retriable.expects(:sleep).with(4)
      retriable.send(:retry!)
      retriable.send(:retry!)
    end

    it "should keep track of retries" do
      retriable = HttpRetriable.new
      assert_equal 0, retriable.retried
      retriable.send(:retry!)
      assert_equal 1, retriable.retried
    end
  end

  describe "call" do
    it "should not raise an error if successful within retry limit" do
      calls = 0
      HttpRetriable.any_instance.expects(:sleep).times(2)
      HttpRetriable.call(:exceptions => StandardError) do |retriable|
        if calls < 7
          calls+=1
          raise StandardError.new('boom')
        end
      end
    end

    it "should raise an error if its never successful" do
      HttpRetriable.any_instance.expects(:sleep).with(2)
      HttpRetriable.any_instance.expects(:sleep).with(4)
      HttpRetriable.any_instance.expects(:sleep).with(8)
      assert_raises StandardError do
        HttpRetriable.call(:retries => 3, :exceptions => StandardError) do |retriable|
          raise StandardError.new('boom')
        end
      end
    end
  end

end

