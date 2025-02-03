require 'rails_helper'

RSpec.describe Ticket, type: :model do
  let(:ticketable) { create(:booking) }
  
  it "applies default values for additional_charges, discounts, and taxes" do
    ticket = Ticket.create!(
      ticketable: ticketable,
      issue_date: Time.current,
      daily_rate: 50,
      rental_days: 5,
      subtotal_rent: 250,
      total_amount: 250
    )
    
    expect(ticket.additional_charges).to eq(0.0)
    expect(ticket.discounts).to eq(0.0)
    expect(ticket.taxes).to eq(0.0)
  end
end
