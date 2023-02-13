class CreateTargetStreams < ActiveRecord::Migration[6.1]
  def change
    create_table :target_streams do |t|
      t.string  :name
      t.string  :input_name
      t.string  :app_name
      t.string  :target_url
      t.string  :target_key
      t.string  :status
      t.boolean :is_relay_from_input
      t.integer :pid
    end
  end
end
