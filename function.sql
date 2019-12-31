DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;
DROP TRIGGER IF EXISTS ticketNumber;

delimiter //

CREATE FUNCTION calculateFreeSeats(FlightN int)
RETURNS int

BEGIN
DECLARE passengers int;
DECLARE result int;
SET passengers = 0;
/*DECLARE FlightN int;
/*SET FlightN = Flightnumber;*/

/*Ticket_number   Pas_makes_Pay bytt mot passanger */
SELECT COUNT(*) into passengers from Pas_in_book where Reservation_number in (SELECT Reservation_number from Booking where Flightnumber = FlightN);

SET result = 40 - passengers;

RETURN (result);

END;


CREATE FUNCTION calculatePrice(FlightN int)

RETURNS float

BEGIN
DECLARE TotalPrice float;
DECLARE Weekday_Fact float;
DECLARE booked_passengers int;
DECLARE profit_factor float;
DECLARE A VARCHAR(3);
DECLARE B VARCHAR(3);
DECLARE C int;
DECLARE route_price int;

SELECT arrival_airport_code, departure_airport_code, year into A,B,C from Weekly_schedule where id in (SELECT weekly_id from Flight where Flightnumber = FlightN);

SELECT routeprice into route_price from Route where arrival_airport_code = A and departure_airport_code = B and year = C;

SELECT Weekdayfactor into Weekday_Fact from Week where day in (SELECT day from Weekly_schedule where id in (SELECT weekly_id from Flight where Flightnumber = FlightN));

/*SELECT routeprice into route_price from Route where year in (SELECT year_id from Year where year_id in (SELECT year from Weekly_schedule where id in (SELECT weekly_id from Flight where Flightnumber = FlightN)));
SELECT Weekdayfactor into Weekday_Fact from Week where year in (SELECT year_id from Year where year_id in (SELECT year from Weekly_schedule where id in (SELECT weekly_id from Flight where Flightnumber = FlightN)));
SELECT  calculateFreeSeats(FlightN) into booked_passengers;*/

SET booked_passengers = 40-calculateFreeSeats(FlightN);

SELECT Profitfactor into profit_factor from Year where year_id in (SELECT year from Weekly_schedule where id in (SELECT weekly_id from Flight where Flightnumber = FlightN));
SET TotalPrice = (route_price*Weekday_Fact*((booked_passengers+1)/40)*profit_factor);



RETURN (TotalPrice);

END;

/*Option1: */
CREATE TRIGGER ticketNumber AFTER INSERT ON Payment FOR EACH ROW
BEGIN


update Pas_in_book
	set Ticket_number = (rand()*1000)-1
	Where Reservation_number=NEW.Reservation_number;
END;

/*
CREATE VIEW allFlights AS
SELECT city from Airport where airport_code in (SELECT departure_airport_code from Route where departure_airport_code in (SELECT departure_airport_code from Weekly_schedule where id in (SELECT weekly_id from Flight)));
*/

//
delimiter ;
