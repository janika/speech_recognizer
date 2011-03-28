require 'speech_recognition'
namespace :recognizer do
  desc "recognizing file"
  task :from_file => :environment do
    files = ["/home/janika/Desktop/magister/sphinx/cmusphinx/pocketsphinx/test/data/goforward.raw", "/home/janika/Desktop/magister/sphinx/cmusphinx/pocketsphinx/test/data/something.raw"]
    file = ENV['FILE'] ? Date.parse(ENV['FILE']) : files.first
    rec = SpeechRecognition::Recognizer.new
      rec.clear()
      File.open(file, "r") do |f|
        # read data in chunks and feed to recognizer  
        while buff = f.read(2*16000)
          puts "."
          rec.feed_data(buff)
          # this is not really needed, it simulates time delay from real audio stream
          sleep(1)
          puts "Current result: #{rec.result}"
        end
      end
    
      rec.feed_end()
      result = rec.wait_final_result()
      puts "OK, recognition done: " + result 
    end
end