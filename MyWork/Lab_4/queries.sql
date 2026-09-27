-- ============================================================
-- Lab 4: OLAP — аналітичні SQL-запити до VideoHub
-- Машута Олександр, ІМ-051, варіант 16
-- ============================================================

-- ============================================================
-- СЕКЦІЯ 1: АГРЕГАТНІ ФУНКЦІЇ ТА GROUP BY / HAVING
-- ============================================================

-- Опис: Загальна кількість відео на кожному каналі.
-- Використовуємо COUNT(*) + GROUP BY для підрахунку відео, згрупованих за user_id (каналом).
-- Результат: для кожного каналу — кількість завантажених відео.
SELECT
    u.username,
    COUNT(v.video_id) AS total_videos
FROM Users u
JOIN Videos v ON u.user_id = v.user_id
GROUP BY u.username
ORDER BY total_videos DESC;

-- Опис: Середня кількість переглядів на канал (AVG + GROUP BY).
-- Обчислюємо середнє значення стовпця views для кожного каналу окремо.
-- Це дозволяє порівняти популярність каналів незалежно від кількості відео.
SELECT
    u.username,
    ROUND(AVG(v.views), 2) AS avg_views
FROM Users u
JOIN Videos v ON u.user_id = v.user_id
GROUP BY u.username
ORDER BY avg_views DESC;

-- Опис: Загальна кількість лайків для кожного відео (COUNT + GROUP BY + JOIN з таблицею Likes).
-- Підраховуємо лише ті записи в таблиці Likes, де is_like = TRUE.
-- LEFT JOIN гарантує, що відео без лайків теж потраплять у результат із нульовим значенням.
SELECT
    v.title,
    COUNT(l.like_id) AS total_likes
FROM Videos v
LEFT JOIN Likes l ON v.video_id = l.video_id AND l.is_like = TRUE
GROUP BY v.video_id, v.title
ORDER BY total_likes DESC;

-- Опис: Канали, сумарна кількість переглядів яких перевищує поріг N (= 1000).
-- GROUP BY каналом, SUM(views) — сума переглядів усіх відео каналу,
-- HAVING фільтрує групи, де сума менша за поріг.
SELECT
    u.username,
    SUM(v.views) AS total_channel_views
FROM Users u
JOIN Videos v ON u.user_id = v.user_id
GROUP BY u.username
HAVING SUM(v.views) > 1000
ORDER BY total_channel_views DESC;

-- Опис: Мінімальна та максимальна тривалість відео в базі (MIN, MAX).
-- Один рядок результату — діапазон тривалостей усієї платформи.
SELECT
    MIN(duration_seconds) AS min_duration,
    MAX(duration_seconds) AS max_duration
FROM Videos;

-- Опис: Мінімальна та максимальна тривалість відео для кожного каналу.
-- GROUP BY каналом, MIN/MAX — діапазон тривалостей контенту кожного автора.
SELECT
    u.username,
    MIN(v.duration_seconds) AS min_duration,
    MAX(v.duration_seconds) AS max_duration
FROM Users u
JOIN Videos v ON u.user_id = v.user_id
GROUP BY u.username
ORDER BY min_duration;

-- ============================================================
-- СЕКЦІЯ 2: ЗАПИТИ З JOIN (різні типи)
-- ============================================================

-- Опис: INNER JOIN — відео разом із їхніми авторами.
-- INNER JOIN повертає лише ті рядки, для яких є збіг за user_id в обох таблицях.
-- Відео без автора (якщо такі є) та користувачі без відео не потраплять у результат.
SELECT
    v.title,
    u.username AS author
FROM Videos v
INNER JOIN Users u ON v.user_id = u.user_id
ORDER BY v.title;

-- Опис: LEFT JOIN — усі користувачі, включно з тими, хто не завантажив жодного відео.
-- LEFT JOIN зберігає всі рядки лівої таблиці (Users). Якщо користувач не має відео,
-- стовпці з Videos будуть NULL. Це корисно для виявлення «неактивних» каналів.
SELECT
    u.username,
    v.title AS video_title
FROM Users u
LEFT JOIN Videos v ON u.user_id = v.user_id
ORDER BY u.username, v.title;

-- Опис: FULL OUTER JOIN — усі користувачі ТА всі відео, включно з неспівпадаючими.
-- FULL OUTER JOIN повертає всі рядки з обох таблиць. Якщо збігу немає — NULL
-- з протилежного боку. Демонструє повну картину: хто має відео, а хто ні,
-- і чи є «сироти» серед відео (без автора).
SELECT
    u.username,
    v.title AS video_title
FROM Users u
FULL OUTER JOIN Videos v ON u.user_id = v.user_id
ORDER BY u.username, v.title;

-- Опис: CROSS JOIN — декартів добуток користувачів × статуси відео (demo).
-- CROSS JOIN поєднує кожен рядок однієї таблиці з кожним рядком іншої.
-- Тут демонструємо всі можливі комбінації користувачів та статусів публічності.
-- На практиці це може бути корисно для побудови матриці звітів.
SELECT
    u.username,
    CASE WHEN v.is_public = TRUE THEN 'public'
         ELSE 'private'
    END AS video_status
FROM Users u
CROSS JOIN (SELECT DISTINCT is_public FROM Videos) v
ORDER BY u.username, video_status;

-- ============================================================
-- СЕКЦІЯ 3: ПІДЗАПИТИ (SELECT, WHERE, HAVING)
-- ============================================================

-- Опис: Підзапит у SELECT — частка переглядів відео відносно сумарних переглядів каналу.
-- Для кожного відео обчислюємо, який відсоток переглядів воно дає своєму каналу.
-- Підзапит (SELECT SUM(views) ... WHERE v2.user_id = v.user_id) повертає
-- суму переглядів каналу, а потім ділимо views відео на цю суму * 100.
SELECT
    v.title,
    v.views,
    (SELECT SUM(v2.views) FROM Videos v2 WHERE v2.user_id = v.user_id) AS channel_total_views,
    ROUND(
        v.views::NUMERIC / NULLIF((SELECT SUM(v2.views) FROM Videos v2 WHERE v2.user_id = v.user_id), 0) * 100,
        2
    ) AS view_share_pct
FROM Videos v
ORDER BY view_share_pct DESC NULLS LAST;

-- Опис: Корельований підзапит у WHERE — відео, перегляди яких перевищують середнє по каналу.
-- Для кожного рядка виконується підзапит, що обчислює AVG(views) для того ж каналу.
-- Це «корельований» підзапит, бо він залежить від зовнішнього рядка (v.user_id).
-- Показує «зіркові» відео, які перевершують середній показник свого каналу.
SELECT
    v.title,
    u.username AS channel,
    v.views,
    (SELECT ROUND(AVG(v2.views), 2) FROM Videos v2 WHERE v2.user_id = v.user_id) AS channel_avg_views
FROM Videos v
JOIN Users u ON v.user_id = u.user_id
WHERE v.views > (SELECT AVG(v2.views) FROM Videos v2 WHERE v2.user_id = v.user_id)
ORDER BY v.views DESC;

-- Опис: Підзапит у HAVING — канали, кількість відео яких перевищує середню по всіх каналах.
-- Спочатку GROUP BY каналом, COUNT(*) — кількість відео.
-- HAVING фільтрує: залишаємо лише канали, де COUNT(*) > (SELECT AVG(...) з підзапиту).
-- Підзапит обчислює середню кількість відео на канал (виконується один раз, не корельований).
SELECT
    u.username,
    COUNT(v.video_id) AS video_count
FROM Users u
JOIN Videos v ON u.user_id = v.user_id
GROUP BY u.username
HAVING COUNT(v.video_id) > (
    SELECT AVG(channel_video_count)
    FROM (
        SELECT COUNT(*) AS channel_video_count
        FROM Videos
        GROUP BY user_id
    ) AS sub
)
ORDER BY video_count DESC;

-- ============================================================
-- СЕКЦІЯ 4: БАГАТОТАБЛИЧНА АГРЕГАЦІЯ
-- ============================================================

-- Опис: Загальна кількість лайків та коментарів для кожного каналу.
-- Об'єднуємо 4 таблиці: Users → Videos → Likes і Users → Videos → Comments.
-- GROUP BY за каналом, COUNT(DISTINCT ...) для уникнення подвійного підрахунку
-- при множенні рядків через JOIN двох незалежних зв'язків.
-- Це класичний приклад багатотабличної агрегації, де потрібно бути обережним
-- із «вибухом» рядків при кількох одночасних JOIN.
SELECT
    u.username AS channel,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments
FROM Users u
JOIN Videos v ON u.user_id = v.user_id
LEFT JOIN Likes l ON v.video_id = l.video_id AND l.is_like = TRUE
LEFT JOIN Comments c ON v.video_id = c.video_id
GROUP BY u.username
ORDER BY total_likes DESC, total_comments DESC;

-- ============================================================
-- СЕКЦІЯ 5: ДОДАТКОВІ АНАЛІТИЧНІ ЗАПИТИ
-- ============================================================

-- Опис: Загальна кількість користувачів, відео, коментарів та лайків у системі.
-- Простий підсумковий звіт про розміри платформи.
SELECT
    (SELECT COUNT(*) FROM Users) AS total_users,
    (SELECT COUNT(*) FROM Videos) AS total_videos,
    (SELECT COUNT(*) FROM Comments) AS total_comments,
    (SELECT COUNT(*) FROM Likes) AS total_likes;

-- Опис: Топ-5 відео за кількістю коментарів (агрегація + ORDER BY + LIMIT).
-- JOIN Videos + Comments, GROUP BY відео, сортування за спаданням, обрізка до 5.
SELECT
    v.title,
    u.username AS channel,
    COUNT(c.comment_id) AS comment_count
FROM Videos v
JOIN Users u ON v.user_id = u.user_id
LEFT JOIN Comments c ON v.video_id = c.video_id
GROUP BY v.video_id, v.title, u.username
ORDER BY comment_count DESC
LIMIT 5;

-- Опис: Кількість підписників на кожен канал (Subscription + GROUP BY).
-- Аналітичний запит для розуміння аудиторії кожного каналу.
SELECT
    u.username AS channel,
    COUNT(s.subscriber_id) AS subscriber_count
FROM Users u
LEFT JOIN Subscriptions s ON u.user_id = s.channel_id
GROUP BY u.username
ORDER BY subscriber_count DESC;
