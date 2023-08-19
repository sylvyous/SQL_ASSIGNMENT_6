WITH CTE_TOP3_CATEGORIES AS
(
	SELECT 
		se_rental.customer_id,
		se_category.name as genre,
		COUNT(se_rental.rental_id) AS total_rentals
	FROM public.rental AS se_rental
	INNER JOIN public.inventory AS se_inventory
	ON se_inventory.inventory_id = se_rental.inventory_id
	INNER JOIN public.film AS se_film
	ON se_film.film_id = se_inventory.film_id
	INNER JOIN public.film_category AS se_film_category
	ON se_film_category.film_id = se_film.film_id
	INNER JOIN public.category AS se_category
	ON se_category.category_id = se_film_category.category_id
	GROUP BY
		se_rental.customer_id,
		se_category.name
	ORDER BY customer_id, COUNT(se_rental.rental_id) DESC
	
)
select * from(
SELECT 
        customer_id,
		genre,
        ROW_NUMBER() OVER (PARTITION by customer_id ORDER BY total_rentals DESC)
FROM CTE_TOP3_CATEGORIES) part
where row_number IN (1,2,3)
ORDER BY customer_id




WITH CTE_RENTAL AS(
	SELECT	se_film.title as movie_name,
			se_film.rental_rate AS rental_rate,
			se_inventory.inventory_id
	FROM rental AS se_rental
	LEFT OUTER JOIN inventory AS se_inventory
		ON se_rental.inventory_id = se_inventory.inventory_id
	INNER JOIN film AS se_film
		ON se_inventory.film_id = se_film.film_id
	GROUP BY se_film.title,se_inventory.inventory_id, se_film.rental_rate
),
 CTE_ALL_RENTAL AS (
	SELECT AVG(rental_rate) 
	FROM film
)
SELECT *,
    CASE
        WHEN CTE_RENTAL.rental_rate < CTE_ALL_RENTAL.avg THEN 'below'
        ELSE 'above'
    END AS film_to_total_avg
FROM CTE_RENTAL
CROSS JOIN CTE_ALL_RENTAL;

















































