SELECT  ac.first_name, ac.last_name, CONCAT(ac.first_name,' ',  ac.last_name) AS ActorName
FROM actor ac

#2a 
SELECT  ac.actor_id ,ac.first_name, ac.last_name
FROM actor ac
WHERE ac.first_name = 'Joe'

#2a
SELECT  ac.actor_id, ac.first_name, ac.last_name
FROM actor ac
WHERE ac.last_name like '%gen%'

#2c
SELECT  ac.actor_id, ac.first_name, ac.last_name
FROM actor ac
WHERE ac.last_name like '%li%'
ORDER BY ac.last_name, ac.first_name

#2d.
SELECT  co.country_id, co.country
FROM country co
WHERE  co.country in ('Afghanistan', 'Bangladesh', 'China')

#3a
ALTER TABLE actor
ADD COLUMN desctiption BLOB AFTER first_name;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT  ac.last_name, COUNT(ac.first_name) AS Actors
FROM actor ac
GROUP BY ac.last_name

#4b. List last names of actors and the number of actors who have that last name, 
#but only for names that are shared by at least two actors
SELECT tb.last_name, tb.Actors 
FROM ((SELECT  ac.last_name, COUNT(ac.first_name) AS Actors
		FROM actor ac
		GROUP BY ac.last_name)) tb
WHERE tb.Actors>1


#4c
UPDATE 
    actor ac
SET 
    ac.first_name = 'Harpo'
WHERE 
    ac.first_name ='Groucho' AND
    ac.last_name = 'Williams';
    
#4d UPDATE 
UPDATE
    actor ac
SET 
    ac.first_name = 'Groucho'
WHERE 
    ac.first_name ='Harpo' AND
    ac.last_name = 'Williams';
    
#5a 
SHOW CREATE TABLE address;

#6a. Use JOIN to display the first and last names,
# as well as the address, of each staff member. Use the tables staff and address:

SELECT st.first_name, st.last_name, ad.address, ad.address_id, st.address_id
FROM staff st,
	 address ad
WHERE ad.address_id=st.address_id
    
#6b. Use JOIN to display the total amount rung up
# by each staff member in August of 2005. Use tables staff and payment.
SELECT 	tb2.staff_id, tb2.first_name, tb2.last_name, tb2.DateMonth, SUM(tb2.amount) as TotalAmount
FROM 	(SELECT tb.staff_id, tb.first_name, tb.last_name,tb.amount, tb.DateMonth
		FROM (SELECT st.staff_id, st.first_name, st.last_name, py.amount, MONTH(py.payment_date) as DateMonth
				FROM staff st
				 LEFT JOIN payment py
					ON st.staff_id = py.staff_id) tb
		WHERE tb.DateMonth=8)tb2
GROUP BY  tb2.staff_id


#6c. List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.
SELECT tb.film_id, tb.title, COUNT(tb.actor_id) AS CastNumber
FROM	(SELECT fm.film_id, fm.title, fa.actor_id
		FROM film fm
			 INNER JOIN film_actor fa
			 ON fm.film_id = fa.film_id) tb
GROUP BY tb.film_id

#6d How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT tb.film_id, COUNT(tb.inventory_id) as NumberOfCopies
FROM (	SELECT inv.inventory_id, inv.film_id
		FROM   inventory inv
		WHERE inv.film_id IN (SELECT film_id
				FROM film fm
				WHERE fm.title= "Hunchback Impossible") ) tb
GROUP BY tb.film_id
	
    
# 6e. Using the tables payment and customer and the JOIN command,
# list the total paid by each customer. List the customers alphabetically by last name:
SELECT tb.customer_id, tb.first_name, tb.last_name, SUM(tb.amount) as TotalPaid
FROM(	SELECT cu.customer_id, cu.first_name, cu.last_name, py.payment_id, py.amount
		FROM customer cu
			 LEFT JOIN payment py
			 ON cu.customer_id=py.customer_id) tb
GROUP BY tb.customer_id
ORDER BY tb.last_name
  

#7a 
SELECT fm.title, fm.language_id
FROM film fm
WHERE (fm.title like 'K%' OR
	  fm.title like 'Q%' ) AND 
      fm.language_id in 
			  (SELECT lg.language_id 
			  FROM language lg
			  WHERE lg.name = 'English')
  
#7b Use subqueries to display all actors who appear in the film Alone Trip
SELECT ac.actor_id, ac.first_name, ac.last_name
FROM actor ac
WHERE ac.actor_id in 
		(SELECT fa.actor_id
		FROM  film_actor fa
		WHERE fa.film_id in 
				(SELECT fm.film_id
					FROM film fm 
					WHERE fm.title='Alone Trip'))
                    
# 7c. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all Canadian customers.                                                
SELECT  t.first_name, t.last_name, t.email, t.country, t.city                                              
FROM	(SELECT cu.first_name, cu.last_name, cu.email, tab2.country, tab2.city
		FROM customer cu,						
					(SELECT tab.country_id, tab.city_id, ad.address_id , tab.country	,tab.city			
					FROM	(SELECT co.country_id , ci.city_id, co.country, ci.city
							FROM  country co
								LEFT JOIN city ci ON co.country_id=ci.country_id) tab
							LEFT JOIN  address ad ON tab.city_id=ad.city_id) tab2 
		 WHERE cu.address_id=tab2.address_id ) t
WHERE t.country = 'Canada'


#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.
SELECT tab1.title, tab1.film_id, tab1.name, tab1.category_id
FROM	(SELECT fm.title, tab.film_id, tab.name, tab.category_id
		FROM	film fm,
				(SELECT ct.name, fc.film_id, ct.category_id
						FROM category ct,
							film_category fc
						WHERE  ct.category_id=fc.category_id) tab
		WHERE fm.film_id=tab.film_id) tab1
 WHERE tab1.name='Family'  
 
 
#7e. Display the most frequently rented movies in descending order. #23


SELECT tb3.film_id, tb3.title, SUM(tb3.TotalRents) AS FrequencyofRent
FROM	(SELECT tb2.film_id, tb2.title, tb2.inventory_id, COUNT(tb2.rental_id) as TotalRents
			FROM	(SELECT tb1.film_id, tb1.title, tb1.inventory_id, tb1.rental_id
					FROM	(SELECT fm.film_id, fm.title, tb.inventory_id, tb.rental_id
							FROM film fm	
								LEFT JOIN (SELECT inv.inventory_id, inv.film_id, rt.rental_id
											FROM  inventory inv
												LEFT JOIN rental rt ON inv.inventory_id=rt.inventory_id) tb 
									ON fm.film_id=tb.film_id) tb1
					WHERE tb1.rental_id is NOT NULL)tb2
			GROUP BY tb2.inventory_id) tb3
GROUP BY tb3.film_id
ORDER BY FrequencyofRent DESC


#7f. Write a query to display how much business, in dollars, each store brought in.

SELECT   st.store_id, tab.totalperrentalid as total_money
FROM (SELECT py.staff_id, SUM(py.amount) AS totalperrentalid
		FROM payment py
		GROUP BY py.staff_id) tab, 
     staff st 
WHERE st.staff_id = tab.staff_id



#7g. Write a query to display for each store its store ID, city, and country.

SELECT st.store_id, tab2.country, tab2.city, tab2.address
FROM store st,						
	(SELECT tab.country_id, tab.city_id, ad.address_id , ad.address, tab.country,tab.city			
	 FROM	(SELECT co.country_id , ci.city_id, co.country, ci.city
			 FROM  country co
				   LEFT JOIN city ci ON co.country_id=ci.country_id) tab
	 LEFT JOIN  address ad ON tab.city_id=ad.city_id) tab2 
WHERE st.address_id=tab2.address_id
                            

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT  x.name, SUM(x.FrequencyofRent) as TotalRents
FROM	(SELECT tb4.film_id, tb4.title,  tb4.FrequencyofRent, ct.category_id, ct.name
				FROM(SELECT tb3.film_id, tb3.title, SUM(tb3.TotalRents) AS FrequencyofRent
					  FROM	(SELECT tb2.film_id, tb2.title, tb2.inventory_id, COUNT(tb2.rental_id) as TotalRents
								FROM	(SELECT tb1.film_id, tb1.title, tb1.inventory_id, tb1.rental_id
										FROM	(SELECT fm.film_id, fm.title, tb.inventory_id, tb.rental_id
												FROM film fm	
													LEFT JOIN (SELECT inv.inventory_id, inv.film_id, rt.rental_id
																FROM  inventory inv
																	LEFT JOIN rental rt ON inv.inventory_id=rt.inventory_id) tb 
														ON fm.film_id=tb.film_id) tb1
										WHERE tb1.rental_id is NOT NULL)tb2
								GROUP BY tb2.inventory_id) tb3
					   GROUP BY tb3.film_id)tb4,
					   film_category fc,
					   category ct
				WHERE  fc.film_id=tb4.film_id  AND
					   fc.category_id=ct.category_id)x
GROUP BY x.name
ORDER BY TotalRents DESC
LIMIT 5


#8a. Create view

CREATE VIEW `top 5 genres` as

SELECT  x.name, SUM(x.FrequencyofRent) as TotalRents
FROM	(SELECT tb4.film_id, tb4.title,  tb4.FrequencyofRent, ct.category_id, ct.name
				FROM(SELECT tb3.film_id, tb3.title, SUM(tb3.TotalRents) AS FrequencyofRent
					  FROM	(SELECT tb2.film_id, tb2.title, tb2.inventory_id, COUNT(tb2.rental_id) as TotalRents
								FROM	(SELECT tb1.film_id, tb1.title, tb1.inventory_id, tb1.rental_id
										FROM	(SELECT fm.film_id, fm.title, tb.inventory_id, tb.rental_id
												FROM film fm	
													LEFT JOIN (SELECT inv.inventory_id, inv.film_id, rt.rental_id
																FROM  inventory inv
																	LEFT JOIN rental rt ON inv.inventory_id=rt.inventory_id) tb 
														ON fm.film_id=tb.film_id) tb1
										WHERE tb1.rental_id is NOT NULL)tb2
								GROUP BY tb2.inventory_id) tb3
					   GROUP BY tb3.film_id)tb4,
					   film_category fc,
					   category ct
				WHERE  fc.film_id=tb4.film_id  AND
					   fc.category_id=ct.category_id)x
GROUP BY x.name
ORDER BY TotalRents DESC
LIMIT 5



#8b Display view 

SELECT * FROM `top 5 genres`

#8c Delete view 
DROP VIEW `top 5 genres`;