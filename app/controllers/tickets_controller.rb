class TicketsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    @tickets = Ticket.all
    render json: @tickets, status: :ok
  end

  def create
    begin
      ticketable = params[:ticketable_type].constantize.find(params[:ticketable_id])
      ticket = TicketGenerator.generate_for(ticketable, ticket_params.to_h.symbolize_keys)
      render json: ticket, status: :created
    rescue NameError, ActiveRecord::RecordNotFound => e
      render json: { error: "Invalid ticketable resource: #{e.message}" }, status: :unprocessable_entity
    end
  end

  def show
    ticket = Ticket.find(params[:id])
    render json: ticket, status: :ok
  end

  private

  def ticket_params
    params.require(:ticket).permit(:daily_rate, :additional_charges, :discounts, :taxes)
  end
end
