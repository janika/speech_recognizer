class RecognizerController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def create 
    new_session = RecognizerSession.new
    SessionPool.add_to_pool(new_session)
    RecognizerPool.add_new_to_active_pool(new_session)
    render :xml => new_session.to_hash.to_xml
  end
  
  def update
    session = SessionPool.find_open_by_id(params[:id])
    if session && params[:file].present?
      file = "#{Rails.root}/tmp/#{params[:file].original_filename}"
      File.open(file, 'wb') do |f|
        f.write params[:file].read
      end
      recognizer = RecognizerPool.get_for_session(session.id)  
      recognizer.work_with_file(file, session)
      render :xml => session.to_hash.to_xml
    else
      render :xml => {:error => "No file or session present", :root => "message"}
    end
  end
  
  def show
    session = SessionPool.find_by_id(params[:id])
    if session
        render :xml => session.to_hash.to_xml
    else
      render :xml => {:error => "Session with id #{params[:id]} not found"}
    end
  end
  
end
