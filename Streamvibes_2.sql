CREATE DATABASE streamvibes_db;
USE streamvibes_db;


CREATE TABLE users (
    user_id           VARCHAR(10),
    username          VARCHAR(100),
    age               VARCHAR(10),
    gender            VARCHAR(20),
    subscription_plan VARCHAR(20),
    country           VARCHAR(50),
    join_date         VARCHAR(20),
    monthly_fee       VARCHAR(10),
    is_active         VARCHAR(10)
);

SELECT * FROM users;

CREATE TABLE content (
    content_id     VARCHAR(10),
    title          VARCHAR(200),
    content_type   VARCHAR(20),
    genre          VARCHAR(30),
    language       VARCHAR(30),
    release_year   VARCHAR(10),
    imdb_score     VARCHAR(10),
    episodes_count VARCHAR(10)
);

CREATE TABLE watch_history (
    watch_id                VARCHAR(10),
    user_id                 VARCHAR(10),
    content_id              VARCHAR(10),
    watch_date              VARCHAR(20),
    watch_percentage        VARCHAR(10),
    watch_duration_minutes  VARCHAR(10),
    device_type             VARCHAR(20),
    watch_status            VARCHAR(20)
);

CREATE TABLE user_reviews (
    review_id    VARCHAR(10),
    user_id      VARCHAR(10),
    content_id   VARCHAR(10),
    rating       VARCHAR(10),
    review_text  VARCHAR(500),
    sentiment    VARCHAR(20),
    review_date  VARCHAR(20)
);

CREATE TABLE users_backup AS SELECT * FROM users;
CREATE TABLE content_backup AS SELECT * FROM content;
CREATE TABLE watch_history_backup AS SELECT * FROM watch_history;
CREATE TABLE user_reviews_backup AS SELECT * FROM user_reviews;

ALTER TABLE users ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE content ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE watch_history ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE user_reviews ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;


--  CHECKING DUPLICATES
SELECT user_id, COUNT(*) as count
FROM users
GROUP BY user_id
HAVING COUNT(*) > 1;

SELECT watch_id, COUNT(*) as count
FROM watch_history
GROUP BY watch_id
HAVING COUNT(*) > 1;


-- deleting duplicates
-- USERS
DELETE FROM users
WHERE row_id NOT IN (
    SELECT * FROM (
        SELECT MIN(row_id)
        FROM users
        GROUP BY user_id
    ) t
);

-- CONTENT
DELETE FROM content
WHERE row_id NOT IN (
    SELECT * FROM (
        SELECT MIN(row_id)
        FROM content
        GROUP BY content_id
    ) t
);

SELECT * FROM content;

-- WATCH HISTORY
DELETE FROM watch_history
WHERE row_id NOT IN (
    SELECT * FROM (
        SELECT MIN(row_id)
        FROM watch_history
        GROUP BY watch_id
    ) t
);

-- USER REVIEWS
DELETE FROM user_reviews
WHERE row_id NOT IN (
    SELECT * FROM (
        SELECT MIN(row_id)
        FROM user_reviews
        GROUP BY review_id
    ) t
);

SET SQL_SAFE_UPDATES = 0;


-- Handling Missing values
UPDATE content SET genre = NULL WHERE genre = '';
UPDATE content SET language = NULL WHERE language = '';
UPDATE content SET imdb_score = NULL WHERE imdb_score = '';
UPDATE content SET episodes_count = NULL WHERE episodes_count = '';

UPDATE users SET age = NULL WHERE age = '';
UPDATE users SET monthly_fee = NULL WHERE monthly_fee = '';
UPDATE users SET join_date = NULL WHERE join_date = '';
UPDATE users SET is_active = NULL WHERE is_active = '';

UPDATE watch_history SET watch_percentage = NULL WHERE watch_percentage = '';
UPDATE watch_history SET watch_duration_minutes = NULL WHERE watch_duration_minutes = '';

UPDATE user_reviews SET rating = NULL WHERE rating = '';
UPDATE user_reviews SET review_text = 'No Review' WHERE review_text = '';
UPDATE user_reviews SET sentiment = 'No Review' WHERE sentiment = '';

-- Standardize Date Formats
UPDATE watch_history
SET watch_date = CASE
    WHEN watch_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN watch_date
    WHEN watch_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
        THEN STR_TO_DATE(watch_date, '%d-%m-%Y')
    WHEN watch_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
        THEN STR_TO_DATE(watch_date, '%m/%d/%Y')
    ELSE NULL
END;

-- Convert Data Types
ALTER TABLE users
MODIFY age INT,
MODIFY monthly_fee DECIMAL(10,2),
MODIFY join_date DATE;

ALTER TABLE content
MODIFY release_year INT,
MODIFY imdb_score DECIMAL(3,1),
MODIFY episodes_count INT;

ALTER TABLE watch_history
MODIFY watch_date DATE,
MODIFY watch_percentage INT,
MODIFY watch_duration_minutes INT;

ALTER TABLE user_reviews
MODIFY rating INT,
MODIFY review_date DATE;

-- Check duplicates
SELECT user_id, COUNT(*) FROM users GROUP BY user_id HAVING COUNT(*) > 1;

-- Check NULLs
SELECT * FROM content WHERE imdb_score IS NULL;

-- Q1.  What are the top 5 most watched genres?
SELECT 
    c.genre,
    COUNT(*) AS total_watches
FROM watch_history w
JOIN content c ON w.content_id = c.content_id
GROUP BY c.genre
ORDER BY total_watches DESC
LIMIT 5;

-- Q2.  Which subscription plan has the most users and what is their average age?
SELECT 
    subscription_plan,
    COUNT(*) AS users_count,
    ROUND(AVG(age),1) AS avg_age
FROM users
GROUP BY subscription_plan
ORDER BY users_count DESC
LIMIT 1;

-- Q3.  Which country has the highest average watch percentage?
SELECT 
    u.country,
    ROUND(AVG(w.watch_percentage),1) AS avg_watch_percentage
FROM watch_history w
JOIN users u ON w.user_id = u.user_id
GROUP BY u.country
ORDER BY avg_watch_percentage DESC
LIMIT 1;

-- Q4.  What are the top 10 highest rated content based on user reviews?
SELECT 
    c.title,
    c.genre,
    c.content_type,
    ROUND(AVG(r.rating),2) AS avg_rating,
    COUNT(r.review_id) AS total_reviews
FROM user_reviews r
JOIN content c ON r.content_id = c.content_id
GROUP BY c.content_id, c.title, c.genre, c.content_type
HAVING COUNT(r.review_id) >= 3
ORDER BY avg_rating DESC
LIMIT 10;

-- Q5.  Which device is most used for watching and what is average watch duration on each device?
SELECT 
    device_type,
    COUNT(*) AS total_watches,
    ROUND(AVG(watch_duration_minutes),1) AS avg_watch_duration
FROM watch_history
GROUP BY device_type
ORDER BY total_watches DESC;

-- Q6.  How many users joined every year and which year had the most signups?
SELECT 
    YEAR(join_date) AS join_year,
    COUNT(*) AS total_signups
FROM users
GROUP BY join_year
ORDER BY total_signups DESC;

-- Q7.  What percentage of content is Movies vs TV Shows?
SELECT 
    content_type,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM content),1) AS percentage
FROM content
GROUP BY content_type;

-- Q8.  Which genre has the highest average IMDB score?
SELECT 
    genre,
    ROUND(AVG(imdb_score),2) AS avg_imdb_score,
    COUNT(*) AS total_titles
FROM content
WHERE imdb_score IS NOT NULL
GROUP BY genre
ORDER BY avg_imdb_score DESC
LIMIT 1;

-- Q9.  What is the drop off rate for each genre?
SELECT 
    c.genre,
    COUNT(*) AS total_watches,
    SUM(CASE WHEN w.watch_status = 'Dropped' THEN 1 ELSE 0 END) AS total_dropped,
    ROUND(
        SUM(CASE WHEN w.watch_status = 'Dropped' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 1
    ) AS drop_off_rate
FROM watch_history w
JOIN content c ON w.content_id = c.content_id
GROUP BY c.genre
ORDER BY drop_off_rate DESC;

-- Q10. Which users are most engaged?
SELECT 
    u.user_id,
    u.username,
    u.country,
    u.subscription_plan,
    COUNT(w.watch_id) AS total_watched,
    ROUND(AVG(w.watch_percentage),1) AS avg_watch_percentage
FROM watch_history w
JOIN users u ON w.user_id = u.user_id
GROUP BY u.user_id, u.username, u.country, u.subscription_plan
HAVING total_watched > 10 
AND avg_watch_percentage > 70
ORDER BY avg_watch_percentage DESC;


-- Q11. What is the average rating given by users from each country and which country gives the highest ratings?
SELECT 
    u.country,
    ROUND(AVG(r.rating),2) AS avg_rating,
    COUNT(r.review_id) AS total_reviews
FROM user_reviews r
JOIN users u ON r.user_id = u.user_id
GROUP BY u.country
ORDER BY avg_rating DESC;
-- Highest country:
SELECT 
    u.country,
    ROUND(AVG(r.rating),2) AS avg_rating
FROM user_reviews r
JOIN users u ON r.user_id = u.user_id
GROUP BY u.country
ORDER BY avg_rating DESC
LIMIT 1;