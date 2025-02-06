class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.references :ticketable, polymorphic: true, null: false
      t.datetime :issue_date
      t.decimal :daily_rate
      t.integer :rental_days
      t.decimal :subtotal_rent
      t.decimal :additional_charges
      t.decimal :discounts
      t.decimal :taxes
      t.decimal :total_amount

      t.timestamps
    end
  end
end
