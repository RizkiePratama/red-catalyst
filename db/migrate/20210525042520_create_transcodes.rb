class CreateTranscodes < ActiveRecord::Migration[6.1]
  def change
    create_table :transcodes do |t|
      t.string  :name
      t.string  :app_name
      t.string  :input_name
      t.integer :profile_id
      t.string  :status
      t.integer :pid
    end
  end
end
