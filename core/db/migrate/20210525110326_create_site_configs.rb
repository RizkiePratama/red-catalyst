class CreateSiteConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :site_configs do |t|
      t.string :name
      t.string :value
    end
  end
end
