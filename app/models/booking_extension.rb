class BookingExtension < ApplicationRecord
  belongs_to :booking
  has_many :tickets, as: :ticketable, dependent: :destroy

  validates :start_date, :end_date, presence: true

  before_save :calculate_total_price

  def rental_days
    (end_date - start_date).to_i
  end

  private

  def calculate_total_price
    daily_rate = 50
    self.total_price = daily_rate * rental_days
  end
end

