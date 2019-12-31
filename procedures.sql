
DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;



delimiter //



CREATE PROCEDURE addYear (IN input_year INT, IN input_factor float)
BEGIN
INSERT IGNORE INTO Year (year_id,Profitfactor)
VALUES (input_year, input_factor);
END;

CREATE PROCEDURE addDay (IN input_year INT, IN input_day VARCHAR(10), IN input_factor float)
BEGIN
INSERT IGNORE INTO Week (year,day,Weekdayfactor)
VALUES (input_year,input_day,input_factor);
END;

/*
Kanske inte behöver stad.
*/
CREATE PROCEDURE addDestination (IN input_airport_code VARCHAR(3), IN input_name VARCHAR(30), IN input_country VARCHAR(30))
BEGIN
INSERT IGNORE INTO Airport (airport_code, city, country)
VALUES (input_airport_code, input_name, input_country);
END;

CREATE PROCEDURE addRoute (IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year int, IN routeprice float)
BEGIN
INSERT IGNORE INTO Route (arrival_airport_code, departure_airport_code, year, routeprice)
VALUES (arrival_airport_code,departure_airport_code,year,routeprice);
END;

CREATE PROCEDURE addFlight (IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN input_year int, IN input_day VARCHAR(10), IN departure_time TIME)
BEGIN
  DECLARE x INT default 1;
  DECLARE y INT;
  INSERT  INTO Weekly_schedule(departure_time,day,arrival_airport_code,departure_airport_code,year)
  VALUES (departure_time,input_day,arrival_airport_code,departure_airport_code,input_year);

/*

Gör loop runt detta så att den gör det 52 gånger.
SELECT id into y FROM Weekly_schedule ORDER BY id DESC LIMIT 1;
*/

  set y = LAST_INSERT_ID();

  WHILE x <= 52 DO

    INSERT IGNORE INTO Flight (weekly_id, week)
    VALUES (y, x);
    SET x = x + 1;

  END WHILE;

END;


CREATE PROCEDURE addReservation (IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year int, IN week int,IN day VARCHAR(10),IN departure_time TIME,IN number_of_passengers int, OUT output_reservation_nr int)
BEGIN
DECLARE week_id int;
DECLARE FlightNumb int;

SELECT id into week_id from Weekly_schedule where (Weekly_schedule.departure_airport_code = departure_airport_code and Weekly_schedule.arrival_airport_code = arrival_airport_code and Weekly_schedule.departure_time = departure_time and Weekly_schedule.day = day and Weekly_schedule.year = year);

IF week_id in(SELECT weekly_id from Flight) THEN


SELECT Flightnumber into FlightNumb from Flight where weekly_id = week_id and Flight.week = week;

IF calculateFreeSeats(FlightNumb)-number_of_passengers >=0 THEN

INSERT  INTO Booking(Flightnumber,booked_passengers)
VALUES (FlightNumb,number_of_passengers);

SET output_reservation_nr = LAST_INSERT_ID();
ELSE
SELECT "There are not enough seats available on the chosen flight" AS MESSAGE;
END IF;
ELSE
SELECT "There exist no flight for the given route, date and time" AS MESSAGE;
END IF;
END;


CREATE PROCEDURE addPassenger (IN reservation_nr int,IN passport_number int,IN name VARCHAR(30))


BEGIN
DECLARE temp BIGINT;
SELECT Creditcard_number into temp from Payment where Payment.Reservation_number = reservation_nr;

IF temp is null THEN


IF reservation_nr in (select Reservation_number from Booking Where Booking.Reservation_number = reservation_nr) THEN


INSERT IGNORE INTO Passenger(Passport_number,name)
VALUES (passport_number,name);

INSERT INTO Pas_in_book(Passport_number,Reservation_number)
VALUES(passport_number,reservation_nr);
ELSE
SELECT "The given reservation number does not exist" AS MESSAGE;
end IF;
ELSE
SELECT "The booking has already been payed and no futher passengers can be added" AS MESSAGE;

END IF;
END;

CREATE PROCEDURE addContact(IN reservation_nr int ,IN passport_number_ int,In email VARCHAR(30), IN phone BIGINT)
BEGIN
DECLARE pass_name VARCHAR(30);
DECLARE Pass_numb int;
/*Pas_in_book Where Pas_in_book.Reservation_number = reservation_nr)*/
/* passport_number in Passs_numb
IF passport_number in (select Passport_number from Booking Where Reservation_number = reservation_nr) THEN*/
IF reservation_nr in (SELECT Reservation_number from Booking) THEN
IF passport_number_ in  (select Passport_number from Pas_in_book Where Reservation_number = reservation_nr)  THEN
  SELECT name INTO pass_name from Passenger where Passenger.Passport_number = passport_number_;
  INSERT INTO Contact (Passport_number,Email,Phone_number)
  VALUES(passport_number_,email,phone);

  UPDATE Booking SET
  Passport_number = passport_number_
  where
   Reservation_number = reservation_nr;
ELSE
SELECT "The person is not a passenger of the reservation" AS MESSAGE;
END IF;
ELSE
SELECT "The given reservation number does not exist" AS MESSAGE;
END IF;
END;

CREATE PROCEDURE addPayment(IN reservation_nr int,IN cardholder_name VARCHAR(30), IN credit_card_number BIGINT)
BEGIN
DECLARE pass_numb int;
DECLARE flight int;
DECLARE passangers int;
DECLARE tot_Prize float;
DECLARE temp int;
DECLARE count int;
DECLARE Passport_paied int;
DECLARE p_number int default 0;

DECLARE null_check int;

/*SELECT PN into pass_numb from (SELECT Passport_number as PN from Passenger where name = cardholder_name) AS PN_table where PN = (SELECT Passport_number from Pas_in_book where Pas_in_book.Reservation_number = reservation_nr);*/

SELECT Passport_number into pass_numb from Booking where Booking.Reservation_number = reservation_nr;
SELECT Flightnumber into flight from Booking where Booking.Reservation_number = reservation_nr;
SELECT booked_passengers into passangers from Booking where Booking.Reservation_number = reservation_nr;
SET temp = calculateFreeSeats(flight);
SET tot_Prize = calculatePrice(flight);



IF reservation_nr not IN (SELECT Reservation_number from Booking) THEN
SELECT "The given reservation number does not exist" AS MESSAGE;

/*IF (pass_numb not null) THEN */
/*IF  reservation_nr NOT EXISTS in (SELECT Reservation_number from Pas_in_book where )*/

ELSE

IF NOT EXISTS (SELECT * from Contact c WHERE c.Passport_number = pass_numb) THEN
/*IF NOT EXISTS (SELECT * FROM Contact c WHERE c.Passport_number = pass_numb and p.Reservation_number = reservation_nr) THEN*/
SELECT "The reservation has no contact yet" AS MESSAGE;
ELSE
IF (temp-passangers) >=0 THEN

INSERT INTO Payment_info(Creditcard_number,name)
VALUES(credit_card_number,cardholder_name);

INSERT INTO Payment(Reservation_number,total_price,booked_passengers,Creditcard_number)
VALUES(reservation_nr,tot_Prize,passangers,credit_card_number);


ELSE
SELECT 'There are not enough seats available on the flight anymore, deleting reservation' AS 'Message';
DELETE FROM Pas_in_book WHERE Reservation_number = reservation_nr;
DELETE FROM Booking WHERE Reservation_number = reservation_nr;
END IF;
END IF;
END IF;

END;


/*SELECT departure_city_name, destination_city_name, departure_time, departure_day,departure_week, departure_year, nr_of_free_seats, current_price_per_seat FROM TDDD37.Question7CorrectResult;
*/



//
delimiter ;
/*
call addYear (1996,13);
call addDay  (1996,'Friday',13);
call addDestination ('ARN', 'Matteus Henriksson', 'Sweden');
call addDestination('CPH', 'Kastrup', 'Denmark');
call addRoute ('ARN', 'CPH',1996,13);
call addFlight ('ARN', 'CPH', 1996, 'Friday', '13:37:00' );



/*
addYear(year, factor);
addDay(year, day, factor);
addDestination(airport_code, name, country);
addRoute(departure_airport_code, arrival_airport_code, year, routeprice);
addFlight(departure_airport_code, arrival_airport_code, year, day, departure_time);
*/
