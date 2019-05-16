class CreateDailyReports < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_reports do |t|
      t.date :date
      t.integer :platform_id
      t.string :advertiser_id
      t.string :advertiser_name
      t.integer :group_advertiser_id
      t.string :order_id
      t.string :order_name
      t.integer :group_order_id
      t.string :schedule_id
      t.string :schedule_name
      t.string :creative_id
      t.string :creative_name
      t.text :creative_image_url
      t.text :click_url
      t.integer :imp
      t.integer :click
      t.integer :cv
      t.decimal :gross
      t.decimal :net
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :lock_version

      t.timestamps
    end
  end
end
