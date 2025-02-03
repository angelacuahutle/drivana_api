class CreateBookingExtensions < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_extensions do |t|
      t.references :booking, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.decimal :total_price

      t.timestamps
    end
  end
end
