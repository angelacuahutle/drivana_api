class Booking < ApplicationRecord
    has_many :booking_extensions, dependent: :destroy
    has_many :tickets, as: :ticketable, dependent: :destroy
  
    validates :car_id, :driver_id, :start_date, :end_date, presence: true
    validates :status, inclusion: { in: %w[pending confirmed cancelled] }

    before_save :calculate_total_price

    def rental_days
      (end_date - start_date).to_i
    end
  
    private
  
    def calculate_total_price
      daily_rate = 50  # Example rate; could be moved to a config
      self.total_price = daily_rate * rental_days
    end
  end
