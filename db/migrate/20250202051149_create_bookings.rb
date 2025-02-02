class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.integer :car_id
      t.integer :driver_id
      t.date :start_date
      t.date :end_date
      t.string :status
      t.decimal :total_price

      t.timestamps
    end
  end
end
