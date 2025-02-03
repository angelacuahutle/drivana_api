require 'rails_helper'
RSpec.describe Booking, type: :model do
    subject { build(:booking) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a car_id' do
      subject.car_id = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without a driver_id' do
      subject.driver_id = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without a start_date or end_date' do
      subject.start_date = nil
      expect(subject).not_to be_valid
      subject.start_date = Date.today
      subject.end_date = nil
      expect(subject).not_to be_valid
    end

    it 'calculates total_price based on rental_days' do
      subject.save
      daily_rate = 50
      expect(subject.total_price).to eq(daily_rate * (subject.end_date - subject.start_date).to_i)
    end
  end

  describe 'associations' do
    it { should have_many(:booking_extensions) }
    it { should have_many(:tickets) }
  end
end
