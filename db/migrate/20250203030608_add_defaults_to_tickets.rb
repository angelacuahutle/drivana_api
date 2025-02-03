class AddDefaultsToTickets < ActiveRecord::Migration[7.0]
  def change
    change_column_default :tickets, :additional_charges, 0.0
    change_column_default :tickets, :discounts, 0.0
    change_column_default :tickets, :taxes, 0.0
    change_column_null :tickets, :additional_charges, false, 0.0
    change_column_null :tickets, :discounts, false, 0.0
    change_column_null :tickets, :taxes, false, 0.0
  end
end
