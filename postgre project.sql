CREATE TABLE movies(
	id VARCHAR(50),
	title VARCHAR(250),
	year INT,
	date_published DATE,
	duration INT,
	country VARCHAR(250),
	worlwide_gross_income Varchar(50),
	languages Varchar(250),
	production_company VARCHAR(200)

);



CREATE TABLE genre(
	movie_id VARCHAR(50),
	genre VARCHAR(50)
	
);

CREATE TABLE director_mapping(
	movie_id VARCHAR(50),
	name_id Varchar(50)

);


CREATE TABLE role_mapping(
	movie_id VARCHAR(50),
	name_id VARCHAR(50),
	category VARCHAR(50)

);


CREATE TABLE names (
    id VARCHAR(50),
    name VARCHAR(250),
    height FLOAT,
    date_of_birth DATE,
    known_for_movies VARCHAR(250)
);


CREATE TABLE ratings (
    movie_id VARCHAR(50),
    avg_rating FLOAT,
    total_votes INT,
    median_rating FLOAT
);


SELECT COUNT(*) FROM movies;

SELECT COUNT(*) FROM genre;

SELECT COUNT(*) FROM director_mapping;

SELECT COUNT(*) FROM role_mapping;

SELECT COUNT(*) FROM ratings;

SELECT COUNT(*) FROM names;


SELECT COUNT(*) FROM movies;
SELECT * FROM movies LIMIT 5;


SELECT 
    COUNT(*) - COUNT(id) AS id_nulls,
    COUNT(*) - COUNT(title) AS title_nulls,
    COUNT(*) - COUNT(year) AS year_nulls,
    COUNT(*) - COUNT(date_published) AS date_published_nulls,
    COUNT(*) - COUNT(duration) AS duration_nulls,
    COUNT(*) - COUNT(country) AS country_nulls,
    COUNT(*) - COUNT(worlwide_gross_income) AS worlwide_gross_income_nulls,
    COUNT(*) - COUNT(languages) AS languages_nulls,
    COUNT(*) - COUNT(production_company) AS production_company_nulls
FROM movies;


SELECT year as Year, COUNT(*) AS number_of_movies
FROM movies
GROUP BY year
ORDER BY year;


SELECT EXTRACT(MONTH FROM date_published) AS Month, COUNT(*) AS number_of_movies
FROM movies
GROUP BY EXTRACT(MONTH FROM date_published)
ORDER BY Month;


SELECT COUNT(*) AS number_of_movies
FROM movies
WHERE year = 2019 AND (country = 'USA' OR country = 'India');


SELECT DISTINCT genre
FROM genre;

SELECT g.genre, COUNT(*) AS movies_count
FROM genre g
JOIN movies m ON g.movie_id = m.id
WHERE m.year = 2019
GROUP BY g.genre
ORDER BY movies_count DESC
LIMIT 1;


SELECT COUNT(*) AS movies_count_one_genre
FROM (SELECT movie_id FROM genre
      GROUP BY movie_id
      HAVING COUNT(genre) = 1) AS single_genre_movies;


SELECT g.genre, ROUND(AVG(m.duration), 2) AS avg_duration
FROM movies m
JOIN genre g ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY avg_duration DESC;


SELECT genre, COUNT(movie_id) AS movie_count,
RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
FROM genre
GROUP BY genre
HAVING genre = 'Thriller';

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM ratings;


SELECT m.title,r.avg_rating,
RANK() OVER (ORDER BY r.avg_rating DESC) AS movie_rank
FROM ratings r
JOIN movies m ON r.movie_id = m.id
ORDER BY r.avg_rating DESC
LIMIT 10;


SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;


SELECT m.production_company, COUNT(*) AS movie_count, 
DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_company_rank
FROM movies m 
JOIN ratings r ON m.id = r.movie_id
WHERE r.avg_rating > 8 AND m.production_company IS NOT NULL
GROUP BY m.production_company;


SELECT g.genre, COUNT(*) AS movie_count
FROM genre g 
JOIN movies m ON g.movie_id = m.id
JOIN ratings r ON r.movie_id = m.id
WHERE EXTRACT (MONTH FROM m.date_published) = 3 
      AND year = 2017
	  AND m.country = 'USA' AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;


SELECT m.title, r.avg_rating, g.genre
FROM genre g 
JOIN movies m ON g.movie_id = m.id
JOIN ratings r ON r.movie_id = m.id
WHERE r.avg_rating > 8 AND m.title LIKE 'The%'
ORDER BY r.avg_rating DESC;


SELECT COUNT(*) AS movie_count
FROM movies m
JOIN ratings r ON m.id = r.movie_id
WHERE m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
AND r.median_rating = 8;


SELECT m.country, SUM(r.total_votes) AS total_votes
FROM movies m
JOIN ratings r ON m.id = r.movie_id
WHERE m.country IN ('Germany', 'Italy')
GROUP BY m.country;


SELECT COUNT(*) - COUNT(name) AS name_nulls,
       COUNT(*) - COUNT(height) AS height_nulls,
	   COUNT(*) - COUNT(date_of_birth) AS date_of_birth_nulls,
	   COUNT(*) - COUNT(known_for_movies) AS known_for_movies_nulls
FROM names



SELECT n.name AS director_name, COUNT(m.id) AS movie_count
FROM names n
JOIN director_mapping dm ON n.id = dm.name_id
JOIN movies m ON dm.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
WHERE r.avg_rating > 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 3;


SELECT n.name AS actor_name, COUNT(m.id) AS movie_count
FROM names n
JOIN role_mapping rm ON n.id = rm.name_id
JOIN movies m ON rm.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
WHERE r.median_rating >= 8 AND rm.category = 'actor'
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;


SELECT 
    m.production_company,
    SUM(r.total_votes) AS vote_count,
    DENSE_RANK() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
FROM movies m
JOIN ratings r ON m.id = r.movie_id
WHERE m.production_company IS NOT NULL
GROUP BY m.production_company
ORDER BY vote_count DESC
LIMIT 3;


SELECT 
    n.name AS actor_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(DISTINCT m.id) AS movie_count,
    ROUND(CAST(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS numeric), 2) AS actor_avg_rating,
    DENSE_RANK() OVER (
        ORDER BY 
            ROUND(CAST(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS numeric), 2) DESC,
            SUM(r.total_votes) DESC
    ) AS actor_rank
FROM names n
JOIN role_mapping rm ON n.id = rm.name_id
JOIN ratings r ON rm.movie_id = r.movie_id
JOIN movies m ON r.movie_id = m.id
WHERE rm.category = 'actor'
  AND m.country LIKE '%India%'
GROUP BY n.name
HAVING COUNT(DISTINCT m.id) >= 5
ORDER BY actor_rank;



SELECT 
    n.name AS actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(DISTINCT m.id) AS movie_count,
    ROUND(SUM(r.avg_rating * r.total_votes)::numeric / SUM(r.total_votes), 2) AS actress_avg_rating,
    RANK() OVER (ORDER BY 
        (SUM(r.avg_rating * r.total_votes)::numeric / SUM(r.total_votes)) DESC,
        SUM(r.total_votes) DESC) AS actress_rank
FROM names n
JOIN role_mapping rm ON n.id = rm.name_id
JOIN ratings r ON rm.movie_id = r.movie_id
JOIN movies m ON r.movie_id = m.id
WHERE rm.category = 'actress'
      AND m.country LIKE '%India%'
      AND m.languages LIKE '%Hindi%'
GROUP BY n.name
HAVING COUNT(DISTINCT m.id) >= 3
ORDER BY actress_rank
LIMIT 5;



SELECT 
    m.title,
    r.avg_rating,
    CASE 
        WHEN r.avg_rating > 8 THEN 'Superhit movie'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movie'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movie'
        WHEN r.avg_rating < 5 THEN 'Flop movie'
    END AS category
FROM movies m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE g.genre = 'Thriller'
ORDER BY r.avg_rating DESC;


SELECT 
    g.genre,
    ROUND(AVG(m.duration), 2) AS avg_duration,
    ROUND(SUM(AVG(m.duration)) OVER (ORDER BY g.genre), 1) AS running_total_duration,
    ROUND(AVG(AVG(m.duration)) OVER (ORDER BY g.genre ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_duration
FROM movies m
JOIN genre g ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY g.genre;





WITH top_genres AS (
    SELECT 
        g.genre
    FROM genre g
    GROUP BY g.genre
    ORDER BY COUNT(g.movie_id) DESC
    LIMIT 3
),
ranked_movies AS (
    SELECT 
        g.genre,
        m.year,
        m.title AS movie_name,
        m.worlwide_gross_income,
        RANK() OVER (PARTITION BY m.year, g.genre ORDER BY m.worlwide_gross_income DESC) AS movie_rank
    FROM movies m
    JOIN genre g ON m.id = g.movie_id
    WHERE g.genre IN (SELECT genre FROM top_genres)
)
SELECT 
    genre,
    year,
    movie_name,
    worlwide_gross_income,
    movie_rank
FROM ranked_movies
WHERE movie_rank <= 5;





-- Top 2 production houses with most hits among multilingual movies
SELECT 
    m.production_company,
    COUNT(m.id) AS movie_count,
    RANK() OVER (ORDER BY COUNT(m.id) DESC) AS prod_comp_rank
FROM movies m
JOIN ratings r ON m.id = r.movie_id
WHERE 
    m.languages LIKE '%,%'        
    AND r.median_rating >= 8      
    AND m.production_company IS NOT NULL
GROUP BY m.production_company
ORDER BY movie_count DESC
LIMIT 2;




SELECT 
    n.name AS actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(CAST(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS numeric), 2) AS actress_avg_rating,
    RANK() OVER (ORDER BY COUNT(m.id) DESC, SUM(r.total_votes) DESC) AS actress_rank
FROM movies m
JOIN ratings r ON m.id = r.movie_id
JOIN role_mapping rm ON m.id = rm.movie_id
JOIN names n ON rm.name_id = n.id
JOIN genre g ON m.id = g.movie_id
WHERE 
    g.genre = 'Drama'         -- only Drama genre
    AND r.avg_rating > 8      -- Super Hit movies
    AND rm.category = 'Actress'  -- only actresses
GROUP BY n.name
ORDER BY movie_count DESC, total_votes DESC
LIMIT 3;




SELECT 
    n.name AS actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(DISTINCT m.id) AS movie_count,
    ROUND(SUM(r.avg_rating * r.total_votes)::numeric / NULLIF(SUM(r.total_votes), 0), 2) AS actress_avg_rating,
    RANK() OVER (ORDER BY COUNT(DISTINCT m.id) DESC) AS actress_rank
FROM 
    names AS n
JOIN 
    role_mapping AS rm ON n.id = rm.name_id
JOIN 
    movies AS m ON rm.movie_id = m.id
JOIN 
    ratings AS r ON m.id = r.movie_id
WHERE 
    rm.category = 'actress'
    AND m.genre ILIKE '%Drama%'
    AND r.avg_rating > 8
GROUP BY 
    n.name
ORDER BY 
    movie_count DESC, actress_avg_rating DESC
LIMIT 3;






-- Step 1: Get all movies per director with previous movie date
WITH director_movies AS (
    SELECT
        n.id AS director_id,
        n.name AS director_name,
        m.id AS movie_id,
        m.date_published,
        m.duration,
        r.avg_rating,
        r.total_votes,
        LAG(m.date_published) OVER (PARTITION BY n.id ORDER BY m.date_published) AS prev_date
    FROM director_mapping dm
    JOIN movies m ON dm.movie_id = m.id
    JOIN names n ON dm.name_id = n.id
    LEFT JOIN ratings r ON m.id = r.movie_id
),
-- Step 2: Compute intervals in days
director_intervals AS (
    SELECT
        director_id,
        director_name,
        movie_id,
        duration,
        avg_rating,
        total_votes,
        prev_date,
        (date_published - prev_date)::INT AS interval_days
    FROM director_movies
)
-- Step 3: Aggregate per director
SELECT
    director_id,
    director_name,
    COUNT(movie_id) AS number_of_movies,
    CASE 
        WHEN COUNT(movie_id) > 1 THEN AVG(interval_days) 
        ELSE NULL 
    END AS avg_inter_movie_days,
    AVG(avg_rating) AS avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration
FROM director_intervals
GROUP BY director_id, director_name
ORDER BY number_of_movies DESC
LIMIT 9;





SELECT g.genre, COUNT(*) AS movie_count
FROM genre g 
JOIN movies m ON g.movie_id = m.id
JOIN ratings r ON r.movie_id = m.id
WHERE EXTRACT (MONTH FROM m.date_published) = 3 
      AND year = 2017
	  AND m.country = 'USA' AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;














