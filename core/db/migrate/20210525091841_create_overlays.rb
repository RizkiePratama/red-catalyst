class CreateOverlays < ActiveRecord::Migration[6.1]
  def change
    create_table :overlays do |t|
      t.string :name
      t.integer :width
      t.integer :height
      t.string :type
      t.string :path
    end
  end
end
