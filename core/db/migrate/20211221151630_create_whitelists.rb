class CreateWhitelists < ActiveRecord::Migration[6.1]
  def change
    create_table :whitelists do |t|
      t.string :name
      t.string :ip
      t.string :desc
    end
  end
end
