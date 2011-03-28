class RecognizerController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def create 
    result = RecognizerSession.create
    render :xml => result.to_xml
  end
  
  def update
    session = RecognizerSession.find_by_id_and_closed(params[:id], false)
    if session && params[:file].present?
      file = "#{Rails.root}/tmp/#{params[:file].original_filename}"
      File.open(file, 'wb') do |f|
        f.write params[:file].read
      end    
      SpeechRecognition.delay.recognize_file(file, session)
      render :xml => {:message => "Files sent"}
    else
      render :xml => {:error => "No file or session present"}
    end
  end
  
  def show
    result = RecognizerSession.find_by_id(params[:id])
    if result
        render :xml => result.to_xml
    else
      render :xml => {:error => "Session with id #{params[:id]} not found"}
    end
  end
  
end
