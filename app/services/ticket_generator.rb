class TicketGenerator
    def self.generate_for(ticketable, additional_data = {})
      daily_rate = additional_data[:daily_rate] || 50
      rental_days = (ticketable.end_date - ticketable.start_date).to_i
      subtotal = daily_rate * rental_days
  
      additional_charges = additional_data[:additional_charges] || 0
      discounts         = additional_data[:discounts]         || 0
      taxes             = additional_data[:taxes]             || (subtotal * 0.1) # 10% tax example
  
      total = subtotal + additional_charges - discounts + taxes
  
      Ticket.create!(
        ticketable: ticketable,
        issue_date: Time.current,
        daily_rate: daily_rate,
        rental_days: rental_days,
        subtotal_rent: subtotal,
        additional_charges: additional_charges,
        discounts: discounts,
        taxes: taxes,
        total_amount: total
      )
    end

    def self.generate_consolidated(booking)
      tickets = []

      booking_ticket = booking.tickets.find_by(ticketable_type: 'Booking')
      booking_ticket ||= generate_for(booking)
      tickets << booking_ticket

      booking.booking_extensions.each do |extension|
        ext_ticket = extension.tickets.find_by(ticketable_type: 'BookingExtension')
        ext_ticket ||= generate_for(extension)
        tickets << ext_ticket
      end
  
      {
        booking_ticket: booking_ticket,
        extension_tickets: tickets[1..],
        consolidated_total: tickets.sum(&:total_amount)
      }
    end
end
class TicketGenerator
  def self.generate_for(ticketable, additional_data = {})
    daily_rate = additional_data[:daily_rate] || 50
    rental_days = (ticketable.end_date - ticketable.start_date).to_i
    subtotal = daily_rate * rental_days

    additional_charges = additional_data[:additional_charges] || 0
    discounts         = additional_data[:discounts]         || 0
    taxes             = additional_data[:taxes]             || (subtotal * 0.1) # 10% tax example

    total = subtotal + additional_charges - discounts + taxes

    Ticket.create!(
      ticketable: ticketable,
      issue_date: Time.current,
      daily_rate: daily_rate,
      rental_days: rental_days,
      subtotal_rent: subtotal,
      additional_charges: additional_charges,
      discounts: discounts,
      taxes: taxes,
      total_amount: total
    )
  end

  def self.generate_consolidated(booking)
    tickets = []

    booking_ticket = booking.tickets.find_by(ticketable_type: 'Booking')
    booking_ticket ||= generate_for(booking)
    tickets << booking_ticket

    booking.booking_extensions.each do |extension|
      ext_ticket = extension.tickets.find_by(ticketable_type: 'BookingExtension')
      ext_ticket ||= generate_for(extension)
      tickets << ext_ticket
    end

    {
      booking_ticket: booking_ticket,
      extension_tickets: tickets[1..],
      consolidated_total: tickets.sum(&:total_amount)
    }
  end
end
