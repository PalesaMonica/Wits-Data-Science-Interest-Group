--Select All data for specific columns
SELECT title,rental_rate,rating FROM film;

--select all data where rental rate is above 4.99
SELECT * FROM film
WHERE rental_rate > 4.0;

--Select Specific columns and sort your data
SELECT title, rental_rate FROM film
ORDER BY rental_rate DESC;

--Aggregate your data and return the average
SELECT COUNT(*)AS total_films,AVG(rental_rate) AS avr_rental
FROM film;