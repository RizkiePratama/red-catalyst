class CreateRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :records do |t|
      t.string :name
      t.string :app_name
      t.string :input_name
      t.string :path
      t.string :status
    end
  end
end
