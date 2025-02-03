require 'rails_helper'

RSpec.describe BookingExtension, type: :model do
  let(:parent_booking) { create(:booking) }
  
  subject { build(:booking_extension, booking: parent_booking, start_date: Date.today, end_date: Date.today + 3) }

  describe "associations" do
    it { should belong_to(:booking) }
    it { should have_many(:tickets).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
  end

  describe "#rental_days" do
    it "returns the correct number of rental days" do
      subject.start_date = Date.today
      subject.end_date = Date.today + 4
      expect(subject.rental_days).to eq(4)
    end
  end

  describe "callbacks" do
    it "calculates total_price before saving" do
      # Given that the model calculates total_price as 50 * rental_days,
      # for start_date = Date.today and end_date = Date.today + 3,
      # we expect total_price to be 50 * 3.
      subject.start_date = Date.today
      subject.end_date = Date.today + 3
      subject.save!
      expect(subject.total_price).to eq(50 * (subject.end_date - subject.start_date).to_i)
    end
  end
end
