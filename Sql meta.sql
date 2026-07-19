

-- Objective questions 
-- 1 chechking of null values and duplicates
-- Check for NULL values 
SELECT
COUNT(*) AS total_rows,
COUNT(id) AS id_not_null,
COUNT(username) AS username_not_null,
COUNT(created_at) AS created_at_not_null
FROM users;

SELECT
COUNT(*) AS total_rows,
SUM(id IS NULL) AS id_nulls,
SUM(image_url IS NULL) AS image_url_nulls,
SUM(user_id IS NULL) AS user_id_nulls,
SUM(created_dat IS NULL) AS created_dat_nulls
FROM photos;

SELECT
COUNT(*) AS total_rows,
SUM(id IS NULL) AS id_nulls,
SUM(comment_text IS NULL) AS comment_text_nulls,
SUM(user_id IS NULL) AS user_id_nulls,
SUM(photo_id IS NULL) AS photo_id_nulls,
SUM(created_at IS NULL) AS created_at_nulls
FROM comments;

SELECT
COUNT(*) AS total_rows,
SUM(user_id IS NULL) AS user_id_nulls,
SUM(photo_id IS NULL) AS photo_id_nulls,
SUM(created_at IS NULL) AS created_at_nulls
FROM likes;

SELECT
COUNT(*) AS total_rows,
SUM(follower_id IS NULL) AS follower_nulls,
SUM(followee_id IS NULL) AS followee_nulls,
SUM(created_at IS NULL) AS created_at_nulls
FROM follows;

SELECT
COUNT(*) AS total_rows,
SUM(id IS NULL) AS id_nulls,
SUM(tag_name IS NULL) AS tag_name_nulls,
SUM(created_at IS NULL) AS created_at_nulls
FROM tags;

SELECT
COUNT(*) AS total_rows,
SUM(CASE WHEN photo_id IS NULL THEN 1 ELSE 0 END) AS photo_id_nulls,
SUM(tag_id IS NULL) AS tag_id_nulls
FROM photo_tags;

-- Checking for duplicate records 

select 
username,
COUNT(*) AS duplicate_count
FROM users
GROUP BY username
HAVING COUNT(*) > 1;

SELECT
    image_url,
    COUNT(*) AS duplicate_count
FROM photos
GROUP BY image_url
HAVING COUNT(*) > 1;

SELECT
    comment_text,
    user_id,
    photo_id,
    COUNT(*) AS duplicate_count
FROM comments
GROUP BY comment_text, user_id, photo_id
HAVING COUNT(*) > 1;

-- the rest of the tables don't require a check because they are composite of primary key and 
-- MySql workbench automatically prevents duplicate records

-- 2
-- what is the distribution of user activity levels

show databases;

select database();

SELECT
    u.id,
    u.username,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(DISTINCT l.photo_id) AS total_likes_given,
    COUNT(DISTINCT c.id) AS total_comments
FROM users u
LEFT JOIN photos p
    ON u.id = p.user_id
LEFT JOIN likes l
    ON u.id = l.user_id
LEFT JOIN comments c
    ON u.id = c.user_id
GROUP BY u.id, u.username
ORDER BY total_posts DESC,
         total_likes_given DESC,
         total_comments DESC;

-- 3
--  finding the average number of tags per post

SELECT 
    ROUND(AVG(tag_count), 2) AS avg_tags_per_post
FROM (
    SELECT 
        p.id,
        COUNT(pt.tag_id) AS tag_count
    FROM photos p
    LEFT JOIN photo_tags pt
        ON p.id = pt.photo_id
    GROUP BY p.id
) AS photo_tag_counts;


-- 4
-- ranking highest engagement rates based on the posts

SELECT
    u.id,
    u.username,
    COUNT(DISTINCT l.user_id) AS total_likes_received,
    COUNT(DISTINCT c.id) AS total_comments_received,
    (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) AS total_engagement,
    DENSE_RANK() OVER (
        ORDER BY (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) DESC
    ) AS engagement_rank
FROM users u
JOIN photos p
    ON u.id = p.user_id
LEFT JOIN likes l
    ON p.id = l.photo_id
LEFT JOIN comments c
    ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY engagement_rank;

-- 5
-- who has highest number of followers and followings
SELECT
    u.id,
    u.username,
    COUNT(DISTINCT f1.follower_id) AS total_followers,
    COUNT(DISTINCT f2.followee_id) AS total_following
FROM users u
LEFT JOIN follows f1
    ON u.id = f1.followee_id
LEFT JOIN follows f2
    ON u.id = f2.follower_id
GROUP BY u.id, u.username
ORDER BY total_followers DESC,
         total_following DESC;

-- 6
-- average engagement rate per post for each user

SELECT
    u.id,
    u.username,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(DISTINCT l.user_id) AS total_likes_received,
    COUNT(DISTINCT c.id) AS total_comments_received,
    ROUND(
        (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) /
        COUNT(DISTINCT p.id),
        2
    ) AS avg_engagement_per_post
FROM users u
JOIN photos p
    ON u.id = p.user_id
LEFT JOIN likes l
    ON p.id = l.photo_id
LEFT JOIN comments c
    ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY avg_engagement_per_post DESC;


-- 7
-- users who have never liked any post
SELECT
    u.id,
    u.username
FROM users u
LEFT JOIN likes l
    ON u.id = l.user_id
WHERE l.user_id IS NULL;


-- 8
-- leverage user-generated content to create more personalized and engaging ad campaigns?

SELECT
    t.tag_name,
    COUNT(pt.photo_id) AS total_posts
FROM tags t
JOIN photo_tags pt
    ON t.id = pt.tag_id
GROUP BY
    t.id,
    t.tag_name
ORDER BY
    total_posts DESC;


-- 9
-- Are there any correlations between user activity levels and specific content types? How can this information guide content creation and curation strategies?
-- The current dataset contains only photo-related information.

-- Since there is no attribute identifying videos or reels, it is not possible to determine whether one content type performs better than another.


-- 10
-- Calculate the total number of likes, comments, and photo tags for each user.
SELECT
    u.id,
    u.username,
    COUNT(DISTINCT l.user_id) AS total_likes_received,
    COUNT(DISTINCT c.id) AS total_comments_received,
    COUNT(DISTINCT pt.tag_id) AS total_photo_tags
FROM users u
JOIN photos p
    ON u.id = p.user_id
LEFT JOIN likes l
    ON p.id = l.photo_id
LEFT JOIN comments c
    ON p.id = c.photo_id
LEFT JOIN photo_tags pt
    ON p.id = pt.photo_id
GROUP BY u.id, u.username
ORDER BY total_likes_received DESC,
         total_comments_received DESC,
         total_photo_tags DESC;

-- 11
-- Rank users based on their total engagement over a month

SELECT
    u.id,
    u.username,
    COUNT(DISTINCT l.user_id) AS total_likes_received,
    COUNT(DISTINCT c.id) AS total_comments_received,
    (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) AS total_engagement,
    DENSE_RANK() OVER (
        ORDER BY (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) DESC
    ) AS engagement_rank
FROM users u
JOIN photos p
    ON u.id = p.user_id
LEFT JOIN likes l
    ON p.id = l.photo_id
LEFT JOIN comments c
    ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY engagement_rank;


-- 12
-- Retrieve the hashtags that have been used in posts with the highest average number of likes

WITH hashtag_likes AS (
    SELECT
        t.id,
        t.tag_name,
        AVG(like_count) AS avg_likes
    FROM (
        SELECT
            pt.tag_id,
            p.id AS photo_id,
            COUNT(l.user_id) AS like_count
        FROM photos p
        JOIN photo_tags pt
            ON p.id = pt.photo_id
        LEFT JOIN likes l
            ON p.id = l.photo_id
        GROUP BY pt.tag_id, p.id
    ) AS photo_likes
    JOIN tags t
        ON photo_likes.tag_id = t.id
    GROUP BY t.id, t.tag_name
)

SELECT
    tag_name,
    ROUND(avg_likes,2) AS average_likes
FROM hashtag_likes
WHERE avg_likes = (
    SELECT MAX(avg_likes)
    FROM hashtag_likes
);

-- 13
-- Retrieve the users who have started following someone after being followed by that person.
-- No of mutuals

SELECT DISTINCT
    u1.username AS first_user,
    u2.username AS second_user
FROM follows f1
JOIN follows f2
    ON f1.follower_id = f2.followee_id
   AND f1.followee_id = f2.follower_id
JOIN users u1
    ON u1.id = f1.follower_id
JOIN users u2
    ON u2.id = f1.followee_id
WHERE u1.id < u2.id;

-- Subjective questions 

-- 1
-- Based on user engagement and activity levels, which users would you consider the most loyal or valuable?

SELECT
    u.id,
    u.username,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(DISTINCT l.user_id) AS total_likes_received,
    COUNT(DISTINCT c.id) AS total_comments_received,
    (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) AS total_engagement
FROM users u
LEFT JOIN photos p
    ON u.id = p.user_id
LEFT JOIN likes l
    ON p.id = l.photo_id
LEFT JOIN comments c
    ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY total_engagement DESC;


-- 2
-- For inactive users, what strategies would you recommend to re-engage them
SELECT
    u.id,
    u.username,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(DISTINCT l.photo_id) AS total_likes,
    COUNT(DISTINCT c.id) AS total_comments
FROM users u
LEFT JOIN photos p
    ON u.id = p.user_id
LEFT JOIN likes l
    ON u.id = l.user_id
LEFT JOIN comments c
    ON u.id = c.user_id
GROUP BY u.id, u.username
HAVING COUNT(DISTINCT p.id) = 0
   AND COUNT(DISTINCT l.photo_id) = 0
   AND COUNT(DISTINCT c.id) = 0;


-- 3
-- Which hashtags or content topics have the highest engagement rates?

WITH hashtag_engagement AS (
    SELECT
        t.id,
        t.tag_name,
        COUNT(DISTINCT l.user_id) AS total_likes,
        COUNT(DISTINCT c.id) AS total_comments,
        (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) AS total_engagement
    FROM tags t
    JOIN photo_tags pt
        ON t.id = pt.tag_id
    JOIN photos p
        ON pt.photo_id = p.id
    LEFT JOIN likes l
        ON p.id = l.photo_id
    LEFT JOIN comments c
        ON p.id = c.photo_id
    GROUP BY t.id, t.tag_name
)

SELECT *
FROM hashtag_engagement
ORDER BY total_engagement DESC;



-- 4
-- Are there any patterns or trends in user engagement based on demographics (age, location, gender) or posting times?

SELECT
    DATE_FORMAT(created_dat, '%H:00') AS posting_hour,
    COUNT(*) AS total_posts
FROM photos
GROUP BY DATE_FORMAT(created_dat, '%H:00')
ORDER BY posting_hour;

-- 5
-- How would you identify potential influencers or brand ambassadors using this dataset?

WITH followers AS (
    SELECT
        followee_id AS user_id,
        COUNT(*) AS total_followers
    FROM follows
    GROUP BY followee_id
),

likes_received AS (
    SELECT
        p.user_id,
        COUNT(*) AS total_likes_received
    FROM photos p
    JOIN likes l
        ON p.id = l.photo_id
    GROUP BY p.user_id
),

comments_received AS (
    SELECT
        p.user_id,
        COUNT(*) AS total_comments_received
    FROM photos p
    JOIN comments c
        ON p.id = c.photo_id
    GROUP BY p.user_id
)

SELECT
    u.id,
    u.username,
    COALESCE(f.total_followers,0) AS total_followers,
    COALESCE(l.total_likes_received,0) AS total_likes_received,
    COALESCE(c.total_comments_received,0) AS total_comments_received,

    (COALESCE(l.total_likes_received,0) +
     COALESCE(c.total_comments_received,0)) AS total_engagement,

    DENSE_RANK() OVER(
        ORDER BY
            COALESCE(f.total_followers,0) DESC,
            (COALESCE(l.total_likes_received,0) +
             COALESCE(c.total_comments_received,0)) DESC
    ) AS influencer_rank

FROM users u

LEFT JOIN followers f
ON u.id=f.user_id

LEFT JOIN likes_received l
ON u.id=l.user_id

LEFT JOIN comments_received c
ON u.id=c.user_id

ORDER BY influencer_rank;


-- 6
-- How would you segment users based on their activity levels (posts, likes, comments) to create targeted marketing campaigns?

WITH user_posts AS (
    SELECT
        user_id,
        COUNT(*) AS total_posts
    FROM photos
    GROUP BY user_id
),
user_followers AS (
    SELECT
        followee_id AS user_id,
        COUNT(*) AS total_followers
    FROM follows
    GROUP BY followee_id
)

SELECT
    u.id,
    u.username,
    COALESCE(up.total_posts,0) AS total_posts,
    COALESCE(uf.total_followers,0) AS total_followers,
    CASE
        WHEN COALESCE(uf.total_followers,0) >= 50 THEN 'High Value Influencer'
        WHEN COALESCE(up.total_posts,0) >= 5 THEN 'Active Creator'
        WHEN COALESCE(up.total_posts,0) = 0 THEN 'Inactive User'
        ELSE 'Regular User'
    END AS user_segment
FROM users u
LEFT JOIN user_posts up
ON u.id = up.user_id
LEFT JOIN user_followers uf
ON u.id = uf.user_id
ORDER BY total_posts DESC,
         total_followers DESC;


-- 7
-- If data on ad campaigns (impressions, clicks, conversions) is available, how would you measure their effectiveness and optimize future campaigns

-- due to lack of data presented it's answered in the word file taking strategy into consideration.

-- 8
-- How can you use user activity data to identify potential brand ambassadors or advocates who could help promote Instagram's initiatives or events?

WITH posts AS (
    SELECT
        user_id,
        COUNT(*) AS total_posts
    FROM photos
    GROUP BY user_id
),

followers AS (
    SELECT
        followee_id AS user_id,
        COUNT(*) AS total_followers
    FROM follows
    GROUP BY followee_id
),

likes_received AS (
    SELECT
        p.user_id,
        COUNT(*) AS total_likes_received
    FROM photos p
    JOIN likes l
        ON p.id = l.photo_id
    GROUP BY p.user_id
),

comments_received AS (
    SELECT
        p.user_id,
        COUNT(*) AS total_comments_received
    FROM photos p
    JOIN comments c
        ON p.id = c.photo_id
    GROUP BY p.user_id
)

SELECT
    u.id,
    u.username,
    COALESCE(po.total_posts, 0) AS total_posts,
    COALESCE(f.total_followers, 0) AS total_followers,
    COALESCE(lr.total_likes_received, 0) AS total_likes_received,
    COALESCE(cr.total_comments_received, 0) AS total_comments_received,
    (COALESCE(lr.total_likes_received, 0) +
     COALESCE(cr.total_comments_received, 0)) AS total_engagement,

    DENSE_RANK() OVER (
        ORDER BY
            COALESCE(f.total_followers, 0) DESC,
            (COALESCE(lr.total_likes_received, 0) +
             COALESCE(cr.total_comments_received, 0)) DESC
    ) AS ambassador_rank
FROM users u
LEFT JOIN posts po
    ON u.id = po.user_id
LEFT JOIN followers f
    ON u.id = f.user_id
LEFT JOIN likes_received lr
    ON u.id = lr.user_id
LEFT JOIN comments_received cr
    ON u.id = cr.user_id
ORDER BY ambassador_rank;


--  9
-- How would you approach this problem if the objective and subjective questions weren't given

-- purely subjective

-- 10
-- Assuming there's a User_Interactions table tracking user engagements, how can you update the Engagement_Type column to change all instances of "Like" to "Heart" to align with Instagram's terminology?

-- UPDATE User_Interactions
-- SET Engagement_Type = 'Heart'
-- WHERE Engagement_Type = 'Like';
-- provided there's no engagement table this query would'nt really perform it's task


