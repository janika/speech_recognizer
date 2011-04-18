class RecognizerController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def create 
    new_session = RecognizerSession.create
    RecognizerPool.add_new_to_pool(new_session)
    render :xml => new_session.to_xml
  end
  
  def update
    session = RecognizerSession.find_by_id_and_closed(params[:id], false)
    if session && params[:file].present?
      file = "#{Rails.root}/tmp/#{params[:file].original_filename}"
      File.open(file, 'wb') do |f|
        f.write params[:file].read
      end
      recognizer = RecognizerPool.get_for_session(session.id)
      recognizer.work_with_file(file, session)
      render :xml => session.to_xml
    else
      render :xml => {:error => "No file or session present", :root => "message"}
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
