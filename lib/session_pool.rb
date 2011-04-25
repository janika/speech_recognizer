module SessionPool
  LIFE_CYCLE_IN_SECONDS = 60
  MAX_OPEN_TIME_IN_SECONDS = 10
  
  def self.pool
    $session_pool
  end
  
  def self.find_open_by_id(session_id)
    session = find_by_id(session_id)
    session && session.closed? ? nil : session
  end
  
  def self.find_by_id(session_id)
    pool.fetch(session_id)
  rescue IndexError
    nil
  end
  
  def self.add_to_pool(session)
    pool[session.id] = session
  end
  
  def self.clean_pool
    pool.values.each do |session|
      if (Time.now - session.created_at) >  LIFE_CYCLE_IN_SECONDS
        pool.delete(session.id)
    	elsif (Time.now - session.created_at) >  MAX_OPEN_TIME_IN_SECONDS
        session.closed_at = Time.now 
        session.system_message = "Session time limit exceeded."
      end
    end
  end
end