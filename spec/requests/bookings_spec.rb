require 'rails_helper'

RSpec.describe "Bookings API", type: :request do
  include Devise::Test::IntegrationHelpers

  before do
    @user = create(:user)
    sign_in @user
  end

  let(:valid_booking_params) do
    { 
      booking: {
        car_id: 1,
        driver_id: 1,
        start_date: Date.today.to_s,
        end_date: (Date.today + 5).to_s,
        status: "confirmed"
      }
    }
  end

  let(:invalid_booking_params) do
    { 
      booking: {
        car_id: nil,
        driver_id: nil,
        start_date: nil,
        end_date: nil,
        status: "confirmed"
      }
    }
  end

  describe "POST /bookings" do
    context "with valid parameters" do
      it "creates a new Booking and generates a ticket" do
        expect {
          post "/bookings", params: valid_booking_params
        }.to change(Booking, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).not_to be_nil
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity" do
        post "/bookings", params: invalid_booking_params
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).not_to be_empty
      end
    end
  end

  describe "POST /bookings/:id/extend" do
    let!(:booking) { create(:booking) }
    let(:valid_extension_params) do
      {
        booking_extension: {
          start_date: (Date.today + 5).to_s,
          end_date: (Date.today + 8).to_s
        }
      }
    end

    it "creates a new BookingExtension and generates its ticket" do
      expect {
        post "/bookings/#{booking.id}/extend", params: valid_extension_params
      }.to change(booking.booking_extensions, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).not_to be_nil
    end
  end

  describe "GET /bookings/:id" do
    let!(:booking) { create(:booking) }
    let!(:extension) { create(:booking_extension, booking: booking, start_date: Date.today + 5, end_date: Date.today + 8) }
    
    it "returns the booking details with associated booking extensions and tickets" do
      get "/bookings/#{booking.id}"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(booking.id)
      expect(json_response["booking_extensions"]).not_to be_empty
    end
  end

  describe "GET /bookings/:id/tickets" do
    let!(:booking) { create(:booking) }
    let!(:extension) { create(:booking_extension, booking: booking, start_date: Date.today + 5, end_date: Date.today + 8) }
    
    it "returns all tickets associated with the booking" do
      get "/bookings/#{booking.id}/tickets"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
    end
  end

  describe "GET /bookings/:id/consolidated_ticket" do
    let!(:booking) { create(:booking) }
    let!(:extension) { create(:booking_extension, booking: booking, start_date: Date.today + 5, end_date: Date.today + 8) }
    
    it "returns a consolidated ticket with breakdown and final total" do
      get "/bookings/#{booking.id}/consolidated_ticket"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key("booking_ticket")
      expect(json_response).to have_key("extension_tickets")
      expect(json_response).to have_key("consolidated_total")
    end
  end
end
