-- 1 	What is the total revenue generated from all rentals in the database? (2.25 Marks)
SELECT SUM(AMOUNT) AS Total_revenue FROM PAYMENT;


-- 2.	How many rentals were made in each month_name? 
SELECT MONTH(RENTAL_DATE) AS MONTH, COUNT(*) FROM RENTAL GROUP BY MONTH ORDER BY MONTH;


-- 3    What is the rental rate of the film with the longest title in the database? (2.25 Marks)
SELECT RENTAL_RATE,TITLE  FROM FILM WHERE LENGTH(TITLE)= (SELECT MAX(LENGTH(TITLE))  FROM FILM);



-- 4.	What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? (2.25 Marks)

SELECT AVG(f.rental_rate) FROM rental R
JOIN inventory I ON r.inventory_id = i.inventory_id
JOIN film F ON i.film_id = f.film_id
WHERE R.rental_date > '2005-05-05 22:04:30' AND RENTAL_DATE < '2005-06-05 22:04:30';

-- 5.	What is the most popular category of films in terms of the number of rentals? (3 Marks)

SELECT COUNT(C.CATEGORY_ID) AS COUNT_, C.CATEGORY_ID , CE.NAME FROM FILM_CATEGORY C
JOIN INVENTORY I ON I.FILM_ID=C.FILM_ID
JOIN RENTAL R ON R.INVENTORY_ID= I.INVENTORY_ID
JOIN CATEGORY CE ON CE.CATEGORY_ID=C.CATEGORY_ID
GROUP BY C.CATEGORY_ID
ORDER BY COUNT_  DESC LIMIT 1
;


-- 6.	Find the longest movie duration from the list of films that have not been rented by any customer? (3 Marks)
SELECT  MAX(LENGTH) FROM FILM WHERE FILM_ID NOT IN (SELECT FILM_ID FROM INVENTORY WHERE INVENTORY_ID IN (SELECT INVENTORY_ID FROM RENTAL))  ;



-- 7.	What is the average rental rate for films, broken down by category? (3 Marks)
SELECT AVG(F.RENTAL_RATE) AS AVERAGE,NAME  FROM FILM F
JOIN FILM_CATEGORY C ON C.FILM_ID=F.FILM_ID
JOIN CATEGORY CA ON CA.CATEGORY_ID= C.CATEGORY_ID
GROUP BY C.CATEGORY_ID
ORDER BY AVERAGE DESC ;

--  8.	What is the total revenue generated from rentals for each actor in the database? (3.5 Marks)

SELECT SUM(P.AMOUNT) AS AVERAGE ,CONCAT(A.FIRST_NAME,' ',a.LAST_NAME) AS NAME FROM PAYMENT P 
JOIN RENTAL R ON R.RENTAL_ID = P.RENTAL_ID
JOIN INVENTORY I ON I.INVENTORY_ID =  R.INVENTORY_ID
JOIN FILM_ACTOR FA ON FA.FILM_ID = I.FILM_ID
JOIN ACTOR A ON A.ACTOR_ID=FA.ACTOR_ID
GROUP BY NAME
ORDER BY AVERAGE DESC ;

-- 9.	Show all the actresses who worked in a film having a "Wrestler" in description. 
select distinct a.first_name, a.last_name from actor A
join film_actor FA on a.actor_id = fA.actor_id
join film F on fA.film_id = f.film_id
where f.description like '%Wrestler%' ;

-- 10.	Which customers have rented the same film more than once? 



select  c.customer_id, count(i.film_id) - count(distinct i.film_id) as repeats from rental r
join customer c on c.customer_id=r.customer_id
join inventory i on i.inventory_id=r.inventory_id
group by  c.customer_id
having repeats > 0

;
-- 11.	How many films in the comedy category have a rental rate higher than the average rental rate? 
select COUNT(*) 
from film join film_category on film.film_id=film_category.film_id
where category_id = (select category_id from category where name = 'Comedy')
and rental_rate > (select avg(rental_rate) from film);

-- 12.	Which films have been rented the most by customers living in each city? 
SELECT c.city,  COUNT(c.city) AS rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN customer cu ON r.customer_id = cu.customer_id
JOIN address a ON cu.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN film f ON i.film_id = f.film_id
GROUP BY c.city;

-- 13. What is the total amount spent by customers whose rental payments exceed $200? 
select p.customer_id,c.first_name,c.last_name, sum(p.amount) as Total_amount from payment p join customer c
 on p.customer_id=c.customer_id
 group by p.customer_id,c.first_name,c.last_name having SUM(amount) > 200;
 
 
  -- 14.	Create a View for the total revenue generated by each staff member, 
 -- broken down by store city with country name? 
CREATE VIEW staff_revenue_by_city AS
SELECT s.staff_id, s.first_name, s.last_name, c.city, co.country, SUM(p.amount) AS total_revenue
FROM staff s
JOIN store st ON s.store_id = st.store_id
JOIN address a ON st.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, c.city, co.country;

 -- 15.	Create a view based on rental information consisting of visiting_day, customer_name,
 -- title of film, no_of_rental_days, amount paid by the customer along with percentage of customer spending

CREATE VIEW rental_info AS
SELECT DATE_FORMAT(r.rental_date, '%Y-%m-%d') AS visiting_day,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       f.title AS film_title,
       DATEDIFF(r.return_date, r.rental_date) AS no_of_rental_days,
       p.amount AS amount_paid,
       ROUND((p.amount / (SELECT SUM(amount) FROM payment WHERE customer_id = p.customer_id) * 100), 2) AS percentage_spending
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON r.customer_id = c.customer_id
JOIN payment p ON r.rental_id = p.rental_id;

-- 16.	Display the customers who paid 50% of their total rental costs within one day. 
SELECT 
    r.customer_id,
    f.film_id,
    DATE(r.rental_date) AS rental_date,
    SUM(p.amount) AS total_payment,
    f.rental_rate
FROM rental r
INNER JOIN payment p ON r.rental_id = p.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
WHERE p.payment_date <= DATE_ADD(r.rental_date, INTERVAL 1 DAY) AND p.amount >= (f.rental_rate/2)
GROUP BY r.customer_id, f.film_id, rental_date, f.rental_rate;


