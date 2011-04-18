module RecognizerPool
  
  def self.pool
    $recognizer_pool
  end
  
  def self.get_for_session(session_id)
    recognizer = pool.fetch(session_id)
    if recognizer.present?
      return recognizer
    else
      raise "Missing recognizer"   
    end
  end
  
  def self.add_new_to_pool(session)
    recognizer = SpeechRecognition::Recognizer.new
    recognizer.clear
    pool[session.id] = recognizer
  end
end