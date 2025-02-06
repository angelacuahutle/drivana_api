class Ticket < ApplicationRecord
  belongs_to :ticketable, polymorphic: true

  validates :issue_date, :daily_rate, :rental_days, :subtotal_rent, :total_amount, presence: true

  # Consider callback or method to recalculate totals if needed.
  def generate_totals
    self.subtotal_rent = daily_rate * rental_days
    self.total_amount = subtotal_rent + additional_charges.to_f - discounts.to_f + taxes.to_f
  end
end
