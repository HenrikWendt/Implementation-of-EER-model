DROP view IF EXISTS ONE;
DROP view IF EXISTS TWO;
DROP view IF EXISTS allFlights;

-- View som med hjälp av TWO används för att skapa allFlights.
CREATE VIEW ONE as
SELECT Flight.week 'departure_week', Weekly_schedule.Day 'departure_day', Weekly_schedule.year 'departure_year', Weekly_schedule.departure_time 'departure_time', Airport.city 'departure_city_name', Flight.Flightnumber 'fly1'
FROM ((Weekly_schedule
INNER JOIN Flight ON Flight.weekly_id = Weekly_schedule.id)
INNER JOIN Airport ON Weekly_schedule.departure_airport_code = Airport.airport_code)
order by Flight.Flightnumber;


CREATE VIEW TWO as
SELECT Airport.city 'destination_city_name', Flight.Flightnumber 'fly2', calculateFreeSeats(Flight.Flightnumber) 'nr_of_free_seats', calculatePrice(Flight.Flightnumber) 'current_price_per_seat'
FROM ((Weekly_schedule
INNER JOIN Flight ON Flight.weekly_id = Weekly_schedule.id)
INNER JOIN Airport ON Weekly_schedule.arrival_airport_code = Airport.airport_code)
order by Flight.Flightnumber;

/*
CREATE VIEW THREE as
SELECT Flight.Flightnumber 'fly3', calculatePrice(Flight.Flightnumber) 'current_price_per_seat'
FROM (Weekly_schedule
INNER JOIN Flight ON Flight.weekly_id = Weekly_schedule.id)
order by Flight.Flightnumber;
*/
CREATE VIEW allFlights as SELECT departure_city_name, destination_city_name, departure_time, departure_day,departure_week, departure_year, nr_of_free_seats,current_price_per_seat FROM (ONE INNER JOIN TWO ON ONE.fly1 = TWO.fly2);
-- Facit

SELECT departure_city_name, destination_city_name, departure_time, departure_day,departure_week, departure_year, nr_of_free_seats, current_price_per_seat FROM TDDD37.Question7CorrectResult;
