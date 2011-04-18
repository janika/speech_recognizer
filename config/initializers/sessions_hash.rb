 $recognizer_pool = {:idle => []}
 
 RecognizerPool::NUMBER_OF_INITIAL_RECOGNIZERS.times do 
   RecognizerPool.pool[:idle] << SpeechRecognition::Recognizer.new
 end