# Drivana Project Documentation

## Overview

Drivana is a monolithic Ruby on Rails application designed for managing bookings and generating tickets. The application uses Devise for authentication (with session-based cookies) and leverages polymorphic associations in the Ticket model to handle both original bookings and booking extensions.

## Architectural Decisions

### Monolithic Architecture
- **Simplicity in Development and Deployment:**  
  By building Drivana as a monolith, all the functionalities (views, controllers, models, and business logic) are contained within a single application. This approach minimizes inter-service communication issues and simplifies testing and deployment.
- **Direct Integration of HTML Views:**  
  The application renders HTML views directly (e.g., for booking extensions), enabling straightforward user interactions through forms without requiring a separate frontend.
- **Session-Based Authentication:**  
  We use Devise with session cookies, avoiding the extra overhead of token-based authentication (like JWT).

### Polymorphic Associations
- **Ticket Model:**  
  The Ticket model uses polymorphic associations to relate to both the Booking and BookingExtension models. This allows a single Ticket model to be reused for different types of transactions without duplicating logic.
- **Benefits of Polymorphism:**  
  - **Flexibility:** A ticket can belong to different record types (e.g., Booking or BookingExtension) using one table.  
  - **Simplified Maintenance:** Business logic for ticket generation is centralized in the `TicketGenerator` service.  
  - **Scalability:** New ticketable models can be added without changing the Ticket model’s schema.

## Endpoints

### Authentication
- **Sign In**  
  - **URL:** `POST /users/sign_in`  
  - **Request Body (JSON):**
    ```json
    {
      "user": {
        "email": "test@example.com",
        "password": "password"
      }
    }
    ```
  - **Response:** A session cookie (`_drivana_api_session`) is set, and a status of 200 is returned.

- **Sign Up**  
  - **URL:** `POST /users`  
  - **Request Body (JSON):**
    ```json
    {
      "user": {
        "email": "new@example.com",
        "password": "password",
        "password_confirmation": "password"
      }
    }
    ```
  - **Response:** Creates a new user and returns the appropriate status.

### Bookings
- **List All Bookings**  
  - **URL:** `GET /bookings`
- **Create a Booking**  
  - **URL:** `POST /bookings`  
  - **Request Body (JSON):**
    ```json
    {
      "booking": {
        "car_id": 1,
        "driver_id": 1,
        "start_date": "2025-02-05",
        "end_date": "2025-02-10",
        "status": "confirmed"
      }
    }
    ```
  - **Response:** Returns the created booking with status 201.
- **Show Booking Details**  
  - **URL:** `GET /bookings/:id`  
  - **Response:** Includes booking details along with associated booking extensions and tickets.
- **Extend a Booking (Form)**  
  - **URL:** `GET /bookings/:id/extend_form`  
  - **Response:** Renders an HTML form for extending a booking.
- **Process Booking Extension**  
  - **URL:** `POST /bookings/:id/extend`  
  - **Request Body (when submitted from the form):**
    ```json
    {
      "booking_extension": {
        "start_date": "2025-02-06",
        "end_date": "2025-02-09"
      }
    }
    ```
  - **Response:** Creates the booking extension and generates its associated ticket.
- **Retrieve Tickets for a Booking**  
  - **URL:** `GET /bookings/:id/tickets`  
  - **Response:** Returns all tickets (original and extension tickets) for the booking.
- **Retrieve Consolidated Ticket**  
  - **URL:** `GET /bookings/:id/consolidated_ticket`  
  - **Response:** Returns a consolidated ticket that aggregates the amounts from the original booking and its extensions.

### Tickets
- **Manual Ticket Generation**  
  - **URL:** `POST /tickets`  
  - **Response:** Allows manual ticket creation.
- **Show a Ticket**  
  - **URL:** `GET /tickets/:id`

## Routes (config/routes.rb)

```ruby
Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }

  root "bookings#index"

  resources :bookings, only: [:create, :show, :index] do
    member do
      get  :extend_form         # Renders the extension form
      post :extend              # Processes the extension submission
      get  :tickets
      get  :consolidated_ticket
    end
  end

  resources :tickets, only: [:index, :create, :show]
end
```

## Controllers & Service Object

### BookingsController (app/controllers/bookings_controller.rb)

```ruby
class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show, :extend_form, :extend, :tickets, :consolidated_ticket]

  def index
    @bookings = Booking.all
    render json: @bookings
  end

  def show
    render json: @booking, include: [:booking_extensions, :tickets]
  end

  def create
    @booking = Booking.new(booking_params)
    if @booking.save
      TicketGenerator.generate_for(@booking)
      render json: @booking, status: :created
    else
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def extend_form
    # Renders the HTML form for extending a booking.
  end

  def extend
    @extension = @booking.booking_extensions.new(extension_params)
    if @extension.save
      TicketGenerator.generate_for(@extension)
      redirect_to booking_path(@booking), notice: "Booking extended successfully."
    else
      render json: { errors: @extension.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def tickets
    booking_tickets = @booking.tickets
    extension_tickets = @booking.booking_extensions.includes(:tickets).map(&:tickets).flatten
    all_tickets = booking_tickets + extension_tickets
    render json: all_tickets
  end

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

  def extension_params
    params.require(:booking_extension).permit(:start_date, :end_date)
  end
end
```

### TicketGenerator Service (app/services/ticket_generator.rb)

```ruby
class TicketGenerator
  DEFAULT_DAILY_RATE = 50
  DEFAULT_TAX_RATE   = 0.1

  def self.generate_for(ticketable, additional_data = {})
    daily_rate = additional_data.fetch(:daily_rate, DEFAULT_DAILY_RATE)
    rental_days = (ticketable.end_date - ticketable.start_date).to_i
    subtotal = daily_rate * rental_days

    additional_charges = additional_data.fetch(:additional_charges, 0)
    discounts         = additional_data.fetch(:discounts, 0)
    taxes             = additional_data.fetch(:taxes, subtotal * DEFAULT_TAX_RATE)

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
end
```

## Setup & Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/drivana.git
   cd drivana
   ```

2. **Install Dependencies:**

   ```bash
   bundle install
   ```

3. **Set Up the Database:**

   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Run the Server:**

   ```bash
   rails s
   ```

5. **Run Tests:**

   ```bash
   bundle exec rspec
   ```

## Testing Endpoints with Postman

- **Authentication:**  
  Use the sign-in endpoint (`POST /users/sign_in`) with a JSON body:
  ```json
  {
    "user": {
      "email": "test@example.com",
      "password": "password"
    }
  }
  ```
  Postman will capture the session cookie for subsequent requests.

- **Extend a Booking:**  
  Visit the extension form at `GET /bookings/:id/extend_form` to render the HTML form. Submit the form (which sends a `POST` request to `/bookings/:id/extend`) with:
  ```json
  {
    "booking_extension": {
      "start_date": "2025-02-06",
      "end_date": "2025-02-09"
    }
  }
  ```

- **Other Endpoints:**  
  Test endpoints for listing bookings, retrieving tickets, and getting the consolidated ticket as documented above.
