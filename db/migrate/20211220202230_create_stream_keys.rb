class CreateStreamKeys < ActiveRecord::Migration[6.1]
  def change
    create_table :stream_keys do |t|
      t.string :app
      t.string :key
    end
  end
end
