
require 'rails_helper'

RSpec.describe Ticket, type: :model do
  let(:ticketable) { create(:booking) }

  subject do
    build(:ticket,
          ticketable: ticketable,
          issue_date: Time.current,
          daily_rate: 50,
          rental_days: 4,
          subtotal_rent: 0,
          additional_charges: 10,
          discounts: 5,
          taxes: 15,
          total_amount: 0
         )
  end

  describe "associations" do
    it { should belong_to(:ticketable) }
  end

  describe "validations" do
    it { should validate_presence_of(:issue_date) }
    it { should validate_presence_of(:daily_rate) }
    it { should validate_presence_of(:rental_days) }
    it { should validate_presence_of(:subtotal_rent) }
    it { should validate_presence_of(:total_amount) }
  end

  describe "#generate_totals" do
    before { subject.generate_totals }

    it "calculates subtotal_rent correctly" do
      expected_subtotal = subject.daily_rate * subject.rental_days
      expect(subject.subtotal_rent).to eq(expected_subtotal)
    end

    it "calculates total_amount correctly" do
      expected_total = (subject.daily_rate * subject.rental_days) + subject.additional_charges.to_f - subject.discounts.to_f + subject.taxes.to_f
      expect(subject.total_amount).to eq(expected_total)
    end
  end
end
