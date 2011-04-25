module SpeechRecognition
  BUFFER_SIZE = 2*16000
  def self.recognize_file(file, session)
    rec = Recognizer.new
    rec.clear
    File.open(file, "r") do |f|
      while buff = f.read(BUFFER_SIZE)
        rec.feed_data(buff)
        session.result =  rec.result
      end
    end
    
    rec.feed_end
    result = rec.wait_final_result
    session.result = result
    session.closed_at = Time.now
  end
  
  class Recognizer
    def initialize()
      @result = ""
      # construct pipeline
      @pipeline = Gst::Parse.launch("appsrc name=appsrc ! audioconvert ! audioresample ! pocketsphinx name=asr ! fakesink")
      
      # define input audio properties
      @appsrc = @pipeline.get_child("appsrc")
      caps = Gst::Caps.parse("audio/x-raw-int,rate=16000,channels=1,signed=true,endianness=1234,depth=16,width=16")
      @appsrc.set_property("caps", caps)
      
      # define behaviour for ASR output
      asr = @pipeline.get_child("asr")
      asr.signal_connect('partial_result') { |asr, text, uttid| 
        #puts "PARTIAL: " + text 
        @result = text 
      }
      asr.signal_connect('result') { |asr, text, uttid| 
        #puts "FINAL: " + text 
        @result = text  
        @queue.push(1)
      }
      
      
      @queue = Queue.new
      
      # This returns when ASR engine has been fully loaded
      asr.set_property('configured', true)
      #@pipeline.pause
      end
      
    # Get current (possibly partial) recognition result
    def result
      @result
    end
      
      # Call this before starting a new recognition
      def clear()
        @result = ""
        @queue.clear
        @pipeline.pause
      end
      
      # Feed new chunk of audio data to the recognizer
      def feed_data(data)
        @pipeline.play      
      buffer=Gst::Buffer.new
        buffer.data = data
        @appsrc.push_buffer(buffer)
    end
    
    # Notify recognizer of utterance end
    def feed_end()
      @appsrc.end_of_stream()
    end
    
    # Wait for the recognizer to recognize the current utterance
    # Returns the final recognition result
    def wait_final_result()
      @queue.pop
      @pipeline.stop
      return @result
    end
        
    def work_with_file(file, session)
      File.open(file, "r") do |f|
        while buff = f.read(BUFFER_SIZE)
          feed_data(buff)
          session.result =  self.result
        end
      end
      
      feed_end
      wait_final_result
      session.result = self.result
      session.closed_at = Time.now
    end
  end
end