-- ================================================================================
-- Lab 3: OLTP — Маніпулювання даними SQL
-- VideoHub Database
-- ================================================================================

-- ================================================================================
-- SELECT QUERIES (5 запитів)
-- ================================================================================

-- Опис: Отримати всі відео конкретного користувача (user_id = 1), відсортовані за датою створення (новіші перші)
SELECT video_id, title, views, is_public, created_at
FROM Video
WHERE user_id = 1
ORDER BY created_at DESC;

-- Опис: Знайти всіх користувачів з Gmail email (фільтрація за допомогою LIKE)
SELECT user_id, username, email, created_at
FROM "User"
WHERE email LIKE '%@gmail.com';

-- Опис: Отримати публічні відео з кількістю переглядів більше 1000
SELECT video_id, title, views, duration_seconds
FROM Video
WHERE is_public = TRUE AND views > 1000
ORDER BY views DESC;

-- Опис: Отримати всі коментарі до конкретного відео (video_id = 1), відсортовані за датою створення
SELECT comment_id, user_id, text, created_at
FROM Comment
WHERE video_id = 1
ORDER BY created_at ASC;

-- Опис: Отримати список всіх каналів (користувачі з is_channel = TRUE)
SELECT user_id, username, email, bio, created_at
FROM "User"
WHERE is_channel = TRUE
ORDER BY created_at;

-- ================================================================================
-- INSERT (додавання нового користувача та відео)
-- ================================================================================

-- Опис: Додати нового користувача в таблицю User
INSERT INTO "User" (username, email, password_hash, avatar_url, bio, is_channel)
VALUES ('new_user_test', 'newuser@example.com', 'hash123', 'https://example.com/avatar.jpg', 'Новий тестовий користувач', TRUE);

-- Опис: Додати нове відео від щойно створеного користувача (user_id = 6, припускаємо що новий користувач отримав цей ID)
INSERT INTO Video (user_id, title, description, video_url, thumbnail_url, duration_seconds, views, is_public)
VALUES (6, 'Тестове відео', 'Опис тестового відео для лабораторної роботи 3', 'https://example.com/video.mp4', 'https://example.com/thumb.jpg', 120, 0, TRUE);

-- ================================================================================
-- UPDATE (зміна існуючих даних)
-- ================================================================================

-- Опис: Збільшити кількість переглядів для конкретного відео (video_id = 1) на 100
UPDATE Video
SET views = views + 100
WHERE video_id = 1;

-- УВАГА: Ніколи не робіть так! Цей запит оновить ВСІ відео в базі даних!
-- UPDATE Video
-- SET views = views + 100;

-- ================================================================================
-- DELETE (видалення даних)
-- ================================================================================

-- Опис: Видалити конкретний коментар за його ID (comment_id = 3)
DELETE FROM Comment
WHERE comment_id = 3;

-- УВАГА: Ніколи не робіть так! Цей запит видалить ВСІ коментарі з бази даних!
-- DELETE FROM Comment;

-- ================================================================================
-- Перевірка результатів
-- ================================================================================

-- Опис: Перевірити що новий користувач доданий
SELECT * FROM "User" WHERE username = 'new_user_test';

-- Опис: Перевірити що нове відео додано
SELECT * FROM Video WHERE user_id = 6;

-- Опис: Перевірити що перегляди відео оновились
SELECT video_id, title, views FROM Video WHERE video_id = 1;

-- Опис: Перевірити що коментар видалено
SELECT * FROM Comment WHERE comment_id = 3;
