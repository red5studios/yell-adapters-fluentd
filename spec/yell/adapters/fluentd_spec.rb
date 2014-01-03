require 'spec_helper'

describe Yell::Adapters::Fluentd do

  class FluentStub
    def tag; @tag; end
    def message; @message; end

    def post(tag,message)
      @tag = tag
      @message = message
    end
  end

  let(:logger) { Yell::Logger.new }

  context "a new Yell::Adapters::Fluentd instance" do
    subject { Yell::Adapters::Fluentd.new }

    its(:host) { should == 'localhost' }
    its(:port) { should == 24224 }
    its(:tag) { should == 'yell' }
  end

  context :host do
    let(:adapter) { Yell::Adapters::Fluentd.new }
    subject { adapter.host }

    before { adapter.host = 'hostname' }

    it { should == 'hostname' }
  end

  context :port do
    let(:adapter) { Yell::Adapters::Fluentd.new }
    subject { adapter.port }

    before { adapter.port = 1234 }

    it { should == 1234 }
  end

  context :write do
    let(:event) { Yell::Event.new(logger, 1, 'Hello World') }
    let(:adapter) { Yell::Adapters::Fluentd.new }

    context :datagrams do
      before do
        @fluent = FluentStub.new
        stub(Fluent::Logger::FluentLogger).new(nil,anything) { @fluent }
      end

      after { adapter.write event }

      it "should receive :version" do
        mock.proxy(@fluent).post("yell",hash_including('version' => '1.0'))
      end

      it "should receive :level" do
        mock.proxy(@fluent).post("yell", hash_including('level' => Yell::Severities[event.level]) )
      end

      it "should receive :short_message" do
        mock.proxy(@fluent).post("yell", hash_including('short_message' => event.messages.first) )
      end

      it "should receive :timestamp" do
        mock.proxy(@fluent).post("yell", hash_including('timestamp' => event.time.to_f) )
      end

      it "should receive :host" do
        mock.proxy(@fluent).post("yell", hash_including('host' => event.hostname) )
      end

      it "should receive :file" do
        mock.proxy(@fluent).post("yell", hash_including('file' => event.file) )
      end

      it "should receive :line" do
        mock.proxy(@fluent).post("yell", hash_including('line' => event.line) )
      end

      it "should receive :method" do
        mock.proxy(@fluent).post("yell", hash_including('_method' => event.method) )
      end

      it "should receive :pid" do
        mock.proxy(@fluent).post("yell", hash_including('_pid' => event.pid) )
      end

      context "given a Hash" do
        let(:event) { Yell::Event.new(logger, 1, 'short_message' => 'Hello World', '_custom_field' => 'Custom Field') }

        it "should receive :short_message" do
          mock.proxy(@fluent).post("yell", hash_including('short_message' => 'Hello World') )
        end

        it "should receive :_custom_field" do
          mock.proxy(@fluent).post("yell", hash_including('_custom_field' => 'Custom Field') )
        end
      end

      context "given an Exception" do
        let(:exception) { StandardError.new('This is an error') }
        let(:event) { Yell::Event.new(logger, 1, exception) }

        before do
          mock(exception).backtrace.times(any_times) { [:back, :trace] }
        end

        it "should receive :short_message" do
          mock.proxy(@fluent).post("yell", hash_including('short_message' => "#{exception.class}: #{exception.message}") )
        end

        it "should receive :long_message" do
          mock.proxy(@fluent).post("yell", hash_including('long_message' => "back\ntrace") )
        end
      end

      context "given a Yell::Event with :options" do
        let(:event) { Yell::Event.new(logger, 1, 'Hello World', "_custom_field" => 'Custom Field') }

        it "should receive :short_message" do
          mock.proxy(@fluent).post("yell", hash_including('short_message' => 'Hello World') )
        end

        it "should receive :_custom_field" do
          mock.proxy(@fluent).post("yell", hash_including('_custom_field' => 'Custom Field') )
        end
      end
    end
  end

end