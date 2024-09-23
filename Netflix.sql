--1. Count the number of Movies vs TV Shows
SELECT type as Type, COUNT(*) as Total_count FROM [Netfilx].[dbo].[netfilx] GROUP BY type;
 
 -- 2. Find the most common rating for movies and TV shows
SELECT
    type,
    rating
FROM
    (
    SELECT
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
    FROM [Netfilx].[dbo].[netfilx]
    GROUP BY type, rating
    ) AS t1
WHERE rank = 1;

--3. List all movies released in a specific year (e.g., 2020)

select * from [Netfilx].[dbo].[netfilx] where type='Movie' and release_year=2020;

--4 .Find the top 5 countries with the most content on Netflix

SELECT top 5
    new_Country,
    Total_content
FROM
    (SELECT
        value AS new_Country,
        COUNT(*) AS Total_content
    FROM
        [Netfilx].[dbo].[netfilx]
    CROSS APPLY
        STRING_SPLIT(country, ',')
    GROUP BY
        value
    ) AS t1
WHERE
    new_Country IS NOT NULL
ORDER BY
    Total_content DESC

-- 5 Identify the longest movie

select * from [Netfilx].[dbo].[netfilx]
where
type='movie'
order by cast(left(duration,CHARINDEX(' ',duration) -1) AS INT) DESC;


--6 Find content added in the last 5 years
SELECT
    *
     from [Netfilx].[dbo].[netfilx]
WHERE
    TRY_CONVERT(DATE, date_added, 101) >= DATEADD(YEAR, -5, GETDATE());

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT
    *,
    value AS director
FROM
    [Netfilx].[dbo].[netfilx]
CROSS APPLY
    STRING_SPLIT(director, ',');
-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM [Netfilx].[dbo].[netfilx]
WHERE 
    type = 'TV Show'
    AND
    CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

	-- 9. Count the number of content items in each genre
select value,count(*) as total_content_item from[Netfilx].[dbo].[netfilx]  cross apply string_split(listed_in,',') group by value;

-- 10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

SELECT TOP 5
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        CAST(COUNT(show_id) AS FLOAT) /
        CAST(
            (SELECT COUNT(show_id) FROM [Netfilx].[dbo].[netfilx]  WHERE country = 'India') AS FLOAT
        ) * 100,
        2
    ) AS avg_release
FROM [Netfilx].[dbo].[netfilx] 
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC;


-- 11. List all movies that are documentaries
select * from [Netfilx].[dbo].[netfilx] where listed_in Like '%Documentaries'


-- 12. Find all content without a director
select * from [Netfilx].[dbo].[netfilx] where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from [Netfilx].[dbo].[netfilx] where cast like '%Salman Khan%' and release_year > year(GETDATE())-10; 

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select top 10 value, count(*) from [Netfilx].[dbo].[netfilx] cross apply 
string_split(cast,',') group by value order by count(*) desc;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT 
    category,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT 
        *,
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM [Netfilx].[dbo].[netfilx]
) AS categorized_content
GROUP BY category, type
ORDER BY type;

