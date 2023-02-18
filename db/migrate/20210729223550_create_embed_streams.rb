class CreateEmbedStreams < ActiveRecord::Migration[6.1]
  def change
    create_table :embed_streams do |t|
      t.string  :url
      t.string  :name
      t.string  :sname
      t.string  :status
      t.integer :pid
    end
  end
end