class TicketGenerator
  DEFAULT_DAILY_RATE = 50
  DEFAULT_TAX_RATE   = 0.1

  def self.generate_for(ticketable, additional_data = {})
    amounts = calculate_amounts(ticketable, additional_data)

    Ticket.create!(
      ticketable: ticketable,
      issue_date: Time.current,
      daily_rate: amounts[:daily_rate],
      rental_days: amounts[:rental_days],
      subtotal_rent: amounts[:subtotal],
      additional_charges: amounts[:additional_charges],
      discounts: amounts[:discounts],
      taxes: amounts[:taxes],
      total_amount: amounts[:total]
    )
  end

  def self.generate_consolidated(booking)
    booking_ticket = booking.tickets.find_by(ticketable_type: 'Booking') || generate_for(booking)

    extension_tickets = booking.booking_extensions.map do |extension|
      extension.tickets.find_by(ticketable_type: 'BookingExtension') || generate_for(extension)
    end

    consolidated_total = ([booking_ticket] + extension_tickets).sum(&:total_amount)

    {
      booking_ticket: booking_ticket,
      extension_tickets: extension_tickets,
      consolidated_total: consolidated_total
    }
  end

  private

  def self.calculate_amounts(ticketable, additional_data)
    daily_rate = additional_data.fetch(:daily_rate, DEFAULT_DAILY_RATE)
    rental_days = (ticketable.end_date - ticketable.start_date).to_i
    subtotal = daily_rate * rental_days

    additional_charges = additional_data.fetch(:additional_charges, 0)
    discounts = additional_data.fetch(:discounts, 0)
    taxes = additional_data.fetch(:taxes, subtotal * DEFAULT_TAX_RATE)

    total = subtotal + additional_charges - discounts + taxes

    {
      daily_rate: daily_rate,
      rental_days: rental_days,
      subtotal: subtotal,
      additional_charges: additional_charges,
      discounts: discounts,
      taxes: taxes,
      total: total
    }
  end
end
