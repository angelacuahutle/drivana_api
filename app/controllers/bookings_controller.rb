class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show, :extend, :tickets, :consolidated_ticket]

  def index
    @bookings = Booking.all
    render json: @bookings
  end

  # POST /bookings
  def create
    @booking = Booking.new(booking_params)
    if @booking.save
      TicketGenerator.generate_for(@booking)
      render json: @booking, status: :created
    else
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /bookings/:id/extend
  def extend
    @extension = @booking.booking_extensions.new(extension_params)
    if @extension.save
      TicketGenerator.generate_for(@extension)
      render json: @extension, status: :created
    else
      render json: { errors: @extension.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /bookings/:id
  def show
    render json: @booking, include: [:booking_extensions, :tickets]
  end

  # GET /bookings/:id/tickets
  def tickets
    booking_tickets = @booking.tickets
    extension_tickets = @booking.booking_extensions.includes(:tickets).map(&:tickets).flatten
    all_tickets = booking_tickets + extension_tickets
    render json: all_tickets
  end

  # GET /bookings/:id/consolidated_ticket
  def consolidated_ticket
    consolidated = TicketGenerator.generate_consolidated(@booking)
    render json: consolidated
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Booking not found" }, status: :not_found
  end

  def booking_params
    params.require(:booking).permit(:car_id, :driver_id, :start_date, :end_date, :status)
  end

  def parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def extension_params
    params.require(:booking_extension).permit(:start_date, :end_date)
  end
end
