/*
Detta måste göras i början för varje table.
*/


SELECT 'Dropping FK' AS 'Message';

SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE Booking
DROP foreign key IF EXISTS fk_book_flight;
ALTER TABLE Booking
DROP foreign key IF EXISTS fk_book_cont;
ALTER TABLE Pas_in_book
DROP foreign key IF EXISTS fk_pib_book;
ALTER TABLE Pas_in_book
DROP foreign key IF EXISTS fk_pib_pass;
ALTER TABLE Flight
DROP foreign key IF EXISTS fk_flight_weeklys;
ALTER TABLE Weekly_schedule
DROP foreign key IF EXISTS fk_weeklys_week;
ALTER TABLE  Weekly_schedule
DROP foreign key IF EXISTS fk_weeklys_route;
ALTER TABLE  Weekly_schedule
DROP foreign key IF EXISTS fk_weeklys_year;
ALTER TABLE Week
DROP foreign key IF EXISTS fk_week_year;
ALTER TABLE Route
DROP foreign key IF EXISTS fk_route_airport_arrival;
ALTER TABLE Route
DROP foreign key IF EXISTS fk_route_airport_departure;
ALTER TABLE Route
DROP foreign key IF EXISTS fk_route_year;
ALTER TABLE Payment
DROP foreign key IF EXISTS fk_payment_payinfo;
/*ALTER TABLE Pas_makes_Pay
DROP foreign key IF EXISTS fk_pmp_passenger;
ALTER TABLE Pas_makes_Pay
DROP foreign key IF EXISTS fk_pmp_payment;*/
ALTER TABLE Contact
DROP foreign key IF EXISTS fk_cont_pass;



SELECT 'Dropping Tables' AS 'Message';

DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Flight CASCADE;
DROP TABLE IF EXISTS Weekly_schedule CASCADE;
DROP TABLE IF EXISTS Week CASCADE;
DROP TABLE IF EXISTS Year CASCADE;
DROP TABLE IF EXISTS Route CASCADE;
DROP TABLE IF EXISTS Airport CASCADE;
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS Payment_info CASCADE;
DROP TABLE IF EXISTS Passenger CASCADE;
/*DROP TABLE IF EXISTS Pas_makes_Pay CASCADE;*/
DROP TABLE IF EXISTS Contact CASCADE;
DROP TABLE IF EXISTS Pas_in_book CASCADE;
/*
DROP PROCEDURE IF EXISTS ;
*/
SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Loading... Building database' AS 'Message';


/*
Måste ändra EER-diagramet, Booked passanger ska ner till Booking.
booking id är nu Reservation number
*/
 CREATE TABLE Booking (
   Reservation_number int auto_increment,
   total_price int,
   booked_passengers int,
   Flightnumber int,
   Passport_number int,
   CONSTRAINT pk_Booking PRIMARY KEY(Reservation_number));

 CREATE TABLE Flight (
   Flightnumber int auto_increment,
   week int,
   weekly_id int,
   CONSTRAINT pk_Flight PRIMARY KEY(Flightnumber));


  CREATE TABLE Pas_in_book (
    Passport_number int,
    Reservation_number int not null,
    Ticket_number BIGINT,
    CONSTRAINT pk_Pas_in_book PRIMARY KEY(Passport_number, Reservation_number));
 /*
 Ändrade Week till Day. I EER och ändra weekday till Day i RM.
 */
 CREATE TABLE Week (
   day VARCHAR(10),
   year int not null,
   Weekdayfactor float,
   CONSTRAINT pk_Week PRIMARY KEY(day,year));

 CREATE TABLE Year (
   year_id int,
   Profitfactor float,
   CONSTRAINT pk_Year PRIMARY KEY(year_id));
 /*
 Ändrar routefactor till routeprice i EER och RM. Lägg till FK på city arrival / departure
 Lägg till FK i RM på både depart och arrival year är även en PK
 */
 CREATE TABLE Route (
   arrival_airport_code VARCHAR(3),
   departure_airport_code VARCHAR(3),
   year int,
   routeprice float,
   CONSTRAINT pk_Route PRIMARY KEY(departure_airport_code, arrival_airport_code, year));


 CREATE TABLE Airport (
   airport_code VARCHAR(3),
   /*Airport_name VARCHAR(30),*/
   city VARCHAR(30),
   country VARCHAR(30),
   CONSTRAINT pk_Airport PRIMARY KEY(airport_code));

 /*
 Booking id är nu Reservation_number ändra i RM


OBS TEST

FLYTTER Ticket_number TILL PAYMENT FRÅN PAS_MAKES_PAY!!!!!!!!

OBSS!!!!

 */
 CREATE TABLE Payment(
   Reservation_number int not null,
   total_price int,
   booked_passengers int,
   Creditcard_number BIGINT,

   CONSTRAINT pk_Payment PRIMARY KEY(Reservation_number));

 /*
Ändrar first name och lastname till Name fixa i EER och RM.
 */
 CREATE TABLE Payment_info (
   Creditcard_number BIGINT,
   name VARCHAR(30),
   CONSTRAINT pk_Payment_info PRIMARY KEY(Creditcard_number));

 /*
Ändrar first name och lastname till Name fixa i EER och RM.
 */
 CREATE TABLE Passenger (
   Passport_number int,
   name VARCHAR(30),
   CONSTRAINT pk_Passenger PRIMARY KEY(Passport_number));

 /*
 Booking id är nu Reservation_number ändra i RM
 HAR FLYTTAT BORT TICKET_NUMBER!!

 CREATE TABLE Pas_makes_Pay (
   Passport_number int,
   Reservation_number int not null,
   Ticket_number BIGINT,
   CONSTRAINT pk_Pas_makes_Pay PRIMARY KEY(Passport_number, Reservation_number));
 */
 /*
Ändrar first name och lastname till Name fixa i EER och RM.
 */
 CREATE TABLE Contact (
   Passport_number int,
   Email VARCHAR(30),
   Phone_number BIGINT,
   CONSTRAINT pk_Contact PRIMARY KEY(Passport_number));

   /*
   Ändrade Day_of_week till Day.
   */
   CREATE TABLE Weekly_schedule (
     id int auto_increment,
     departure_time TIME,
     day VARCHAR(10),
     arrival_airport_code VARCHAR(3),
     departure_airport_code VARCHAR(3),
     year int,
     CONSTRAINT pk_Weekly_schedule PRIMARY KEY(id));

    ALTER TABLE Weekly_schedule AUTO_INCREMENT=1;
    ALTER TABLE Flight AUTO_INCREMENT=1000;
    ALTER TABLE Booking AUTO_INCREMENT=1;


SELECT 'Loading... crafting foreign keys' AS 'Message';

/*BOOKING FK
--ALTER TABLE Booking ADD CONSTRAINT fk_book_cust FOREIGN KEY (customer_id) REFERENCES jbstore(id);
 */
ALTER TABLE Booking ADD CONSTRAINT fk_book_flight FOREIGN KEY (Flightnumber) REFERENCES Flight(Flightnumber);
ALTER TABLE Booking ADD CONSTRAINT fk_book_cont FOREIGN KEY (Passport_number) REFERENCES Contact(Passport_number);
/*
--Flight
*/
ALTER TABLE Flight ADD CONSTRAINT fk_flight_weeklys FOREIGN KEY (weekly_id) REFERENCES Weekly_schedule(id);
/*
--Weekly_schedule
*/
ALTER TABLE Weekly_schedule ADD CONSTRAINT fk_weeklys_route FOREIGN KEY (departure_airport_code,arrival_airport_code,year) REFERENCES Route(departure_airport_code,arrival_airport_code,year);
ALTER TABLE Weekly_schedule ADD CONSTRAINT fk_weeklys_week FOREIGN KEY (day,year) REFERENCES Week(day,year);
ALTER TABLE Weekly_schedule ADD CONSTRAINT fk_weeklys_year FOREIGN KEY (year) REFERENCES Year(year_id);
/*
--Week
*/
ALTER TABLE Week ADD CONSTRAINT fk_week_year FOREIGN KEY (year) REFERENCES Year(year_id);
/*
--Route
*/
ALTER TABLE Route ADD CONSTRAINT fk_route_airport_arrival FOREIGN KEY (arrival_airport_code) REFERENCES Airport(airport_code);
ALTER TABLE Route ADD CONSTRAINT fk_route_airport_departure FOREIGN KEY (departure_airport_code) REFERENCES Airport(airport_code);
ALTER TABLE Route ADD CONSTRAINT fk_route_year FOREIGN KEY (year) REFERENCES Year(year_id);
/*
--Payment
*/
ALTER TABLE Payment ADD CONSTRAINT fk_payment_payinfo FOREIGN KEY (Creditcard_number) REFERENCES Payment_info(Creditcard_number);
ALTER TABLE Payment ADD CONSTRAINT fk_payment_booking FOREIGN KEY (Reservation_number) REFERENCES Booking(Reservation_number);
/*
--Pas_makes_Pay

ALTER TABLE Pas_makes_Pay ADD CONSTRAINT fk_pmp_passenger FOREIGN KEY (Passport_number) REFERENCES Passenger(Passport_number);
ALTER TABLE Pas_makes_Pay ADD CONSTRAINT fk_pmp_payment FOREIGN KEY (Reservation_number) REFERENCES Payment(Reservation_number);
*/
/*
--Contact
*/
ALTER TABLE Contact ADD CONSTRAINT fk_cont_pass FOREIGN KEY (Passport_number) REFERENCES Passenger(Passport_number);
/*
--Pas_makes_Pay
*/
ALTER TABLE Pas_in_book ADD CONSTRAINT fk_pib_book FOREIGN KEY (Reservation_number) REFERENCES Booking(Reservation_number);
ALTER TABLE Pas_in_book ADD CONSTRAINT fk_pib_pass FOREIGN KEY (Passport_number) REFERENCES Passenger(Passport_number);
SELECT 'Maximerat, ajt ses!' AS 'Message';
