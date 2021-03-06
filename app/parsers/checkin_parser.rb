class CheckinParser
  attr_reader :checkin_response
  attr_reader :checkin_record

  def initialize(checkin_response, checkin_record)
    @checkin_response = checkin_response
    @checkin_record = checkin_record
  end

  def passenger_checkins
    checkin_response.body['passengerCheckInDocuments'].map do |doc|
      first_doc = doc['checkinDocuments'][0]
      {
        flight_number: first_doc['flightNumber'],
        boarding_group: first_doc['boardingGroup'],
        boarding_position: first_doc['boardingGroupNumber'],
        checkin: checkin_record,
        passenger: passenger(doc),
        flight: flight(first_doc),
      }
    end
  end

  def passenger(passenger_checkin_document)
    passengers = checkin_record.reservation.passengers
    if passengers.count == 1
      passengers.first
    else
      passengers.where(
        first_name: doc['passenger']['secureFlightFirstName'],
        last_name: doc['passenger']['secureFlightLastName']).first
    end
  end

  def flight(checkin_document)
    checkin_record.reservation.flights.where(flight_number: checkin_document['flightNumber']).first
  end
end
