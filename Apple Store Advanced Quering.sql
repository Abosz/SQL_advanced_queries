SELECT * FROM AppleStore;
SELECT * FROM appleStore_description;

-- Creating one combined table
CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4;

-- Checking new table
SELECT * FROM appleStore_description_combined;

-- Checking for missing values

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE track_name IS NULL;

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS NULL OR user_rating IS NULL OR prime_genre IS NULL;

-- Creating views for the security of tables
CREATE VIEW AppleStore_VIEW AS SELECT * FROM AppleStore;
CREATE VIEW appleStore_desc_VIEW AS SELECT * FROM appleStore_description_combined;

-- Finding how many apps there is per genre
SELECT prime_genre, COUNT(track_name) AS NumberOfApps
FROM AppleStore_VIEW
GROUP BY prime_genre
ORDER BY NumberOfApps DESC;

-- Apps rating
SELECT 	MIN(user_rating) AS MinRating,
		MAX(user_rating) AS MaxRating,
        AVG(user_rating) AS AvgRating
FROM AppleStore_VIEW;

-- Any diffrent currency than USD?
SELECT DISTINCT currency
FROM AppleStore_VIEW;

-- Is there a diffrence in ratings betweeen paid and free apps?
SELECT CASE
			WHEN price > 0 THEN "Paid"
            ELSE "Free"
            END AS Type_of_app,
      		avg(user_rating) AS AvgRating
FROM AppleStore_VIEW
GROUP BY Type_of_app;

-- Does number of supported languages have influnce on ratings?
SELECT CASE
			WHEN lang_num < 10 THEN "Less than 10 language"
            WHEN lang_num BETWEEN 10 AND 30 THEN "10-30 languages"
            ELSE "More than 30"
            END AS NumbOfLang,
      		avg(user_rating) AS AvgRating
FROM AppleStore_VIEW
GROUP BY NumbOfLang;

-- What are genres with low ratings?

SELECT prime_genre, avg(user_rating) AS AvgRating
FROM AppleStore_VIEW
GROUP BY prime_genre
ORDER By AvgRating DESC;

-- Is there a correlation between the lenght of the app description and the user rating?

SELECT CASE
	WHEN length(b.app_desc) < 500 THEN "Short desc"
        WHEN length(b.app_desc) BETWEEN 500 AND 1000 THEN "Medium"
            ELSE "Long desc"
            END AS LenghtOfDesc,
            avg(user_rating) AS AvgRating
FROM AppleStore_VIEW AS A
JOIN appleStore_desc_VIEW AS B
ON a.id - b.id
GROUP BY LenghtOfDesc
ORDER BY AvgRating DESC

-- Checking for app with the highest rating
SELECT prime_genre, track_name, user_rating
FROm (SELECT prime_genre, track_name, user_rating,
  		RANK () OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) as Rank
  		FROM AppleStore_VIEW)
      	AS A
WHERE A.rank = 1