class CreateRecognizerSessions < ActiveRecord::Migration
  def self.up
    create_table :recognizer_sessions do |t|
      t.text :result
      t.boolean :closed, :null => false, :default => false

      t.timestamps
    end
    add_index :recognizer_sessions, :closed
  end

  def self.down
    drop_table :recognizer_sessions
  end
end
