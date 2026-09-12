-- ============================================================
-- AUDIOBOOK ANALYSIS
-- SQL Analytics Project
-- Database: PostgreSQL
-- ============================================================


-- ============================================================
-- 1. CORALINE ANALYSIS
-- How many users added "Coraline" and how many listened
-- to more than 10% of the audiobook?
-- ============================================================

SELECT
    COUNT(DISTINCT ac.user_id) AS users_added,
    COUNT(DISTINCT CASE
        WHEN l.finished_at - l.started_at >
             (a.duration * 0.10)
        THEN l.user_id
    END) AS users_listened_more_than_10_percent
FROM audiobooks a
LEFT JOIN audio_cards ac
    ON a.uuid = ac.audiobook_uuid
LEFT JOIN listenings l
    ON a.uuid = l.audiobook_uuid
WHERE a.title = 'Coraline'
  AND (l.is_test = 0 OR l.is_test IS NULL);


-- ============================================================
-- 2. LISTENING ANALYSIS BY OPERATING SYSTEM AND BOOK
-- For each OS and book:
--   - number of unique users
--   - total listening time in hours
-- Test listenings are excluded.
-- ============================================================

SELECT
    l.os_name,
    a.title,
    COUNT(DISTINCT l.user_id) AS total_users,
    ROUND(
        SUM(
            EXTRACT(EPOCH FROM
                (l.finished_at - l.started_at)
            )
        ) / 3600,
        2
    ) AS total_hours_listened
FROM audiobooks a
JOIN listenings l
    ON a.uuid = l.audiobook_uuid
WHERE l.is_test = 0
GROUP BY
    l.os_name,
    a.title
ORDER BY
    l.os_name,
    total_hours_listened DESC;


-- ============================================================
-- 3. MOST POPULAR BOOK
-- Find the book listened to by the largest number
-- of unique users.
-- Test listenings are excluded.
-- ============================================================

SELECT
    a.title,
    COUNT(DISTINCT l.user_id) AS total_users
FROM audiobooks a
JOIN listenings l
    ON a.uuid = l.audiobook_uuid
WHERE l.is_test = 0
GROUP BY
    a.uuid,
    a.title
ORDER BY
    total_users DESC
LIMIT 1;


-- ============================================================
-- 4. MOST COMPLETED BOOK
-- Find the book that is completed by the largest
-- number of users.
-- Test listenings are excluded.
-- ============================================================

SELECT
    a.title,
    COUNT(DISTINCT l.user_id) AS completed_users
FROM audiobooks a
JOIN listenings l
    ON a.uuid = l.audiobook_uuid
WHERE l.is_test = 0
  AND l.finished_at IS NOT NULL
  AND l.started_at IS NOT NULL
  AND (
      EXTRACT(EPOCH FROM
          (l.finished_at - l.started_at)
      ) >= a.duration
  )
GROUP BY
    a.uuid,
    a.title
ORDER BY
    completed_users DESC
LIMIT 1;
