-- ============================================================================
-- VideoHub — тестові дані (INSERT statements)
-- Лабораторна робота №2
-- Автор: Машута Олександр, ІМ-051
-- ============================================================================
-- Порядок вставок визначається залежностями зовнішніх ключів:
-- 1. "user"          — батьківська таблиця, не має FK
-- 2. video           — посилається на "user"
-- 3. comment         — посилається на "user" та video
-- 4. "like"          — посилається на "user" та video
-- 5. subscription    — посилається на "user" (обидва стовпці)
-- ============================================================================

-- ============================================================================
-- 1. Користувачі ("user")
-- ============================================================================
-- Мікс: канали (is_channel=TRUE) та звичайні глядачі.
-- Один користувач автентифікується лише через Google (password_hash = NULL, google_id задан).
-- У решти — парольна автентифікація (google_id = NULL).
-- ============================================================================

INSERT INTO "user" (user_id, username, email, password_hash, google_id, avatar_url, bio, is_channel)
VALUES
    -- Канал 1: технічний блогер
    (1, 'TechWithDeny', 'techwithdeny@videohub.io',
     '$2b$12$abcdefgh1234567890abcdefghijkl', NULL,
     'https://cdn.videohub.io/avatars/techwithdeny.jpg',
     'Огляди новітніх технологій, туторіали з програмування та код-ревʼю.',
     TRUE),

    -- Канал 2: музичний канал
    (2, 'MusicVibes', 'vibes@musicvibes.com',
     '$2b$12$xyz9876543210qwertyuiopasdfghj', NULL,
     'https://cdn.videohub.io/avatars/musicvibes.png',
     'Кавери, оригінальні треки та живі виступи. Підписуйся!',
     TRUE),

    -- Канал 3: науково-популярний канал
    (3, 'ScienceHubUA', 'science@sciencehub.ua',
     '$2b$12$mnbvcxz0987654321lkjhgfdsap', NULL,
     'https://cdn.videohub.io/avatars/sciencehub.png',
     'Цікаві факти про науку, космос, біологію та фізику простими словами.',
     TRUE),

    -- Звичайний глядач 1 (парольна автентифікація)
    (4, 'Olena_Guest', 'olena.guest@example.com',
     '$2b$12$qwerty1234567890asdfghjklzxcv', NULL,
     NULL,
     NULL,
     FALSE),

    -- Звичайний глядач 2 (парольна автентифікація)
    (5, 'AndriyViewer', 'andriy.viewer@example.com',
     '$2b$12$zxcvbnm0987654321poiuytrewqlk', NULL,
     NULL,
     'Люблю дивитися документалістки та технологічні відео.',
     FALSE),

    -- Користувач, який автентифікується ТІЛЬКИ через Google OAuth
    -- password_hash = NULL, тому ця колонка не заповнюється
    (6, 'GoogleUserMax', 'max.smith@gmail.com',
     NULL, '109283746501928374650',
     'https://lh3.googleusercontent.com/a/maxsmith.jpg',
     'Увійшов через Google. Пароль не встановлено.',
     FALSE);

-- Перевірка: всі 6 користувачів додано
SELECT user_id, username, email, is_channel, google_id FROM "user";


-- ============================================================================
-- 2. Відео (video)
-- ============================================================================
-- Кожне відео належить одному каналу (user_id → "user" WHERE is_channel = TRUE).
-- Мікс: публічні та приватні, різна тривалість, перегляди.
-- ============================================================================

INSERT INTO video (video_id, user_id, title, description, video_url, thumbnail_url, duration_seconds, views, is_public)
VALUES
    -- Відео від каналу TechWithDeny (user_id = 1)
    (1, 1,
     'PostgreSQL для початківців: повний туторіал 2026',
     'У цьому відео розбираємо основи PostgreSQL: встановлення, створення таблиць, SELECT, JOIN та ін.',
     'https://cdn.videohub.io/videos/pg_tutorial_2026.mp4',
     'https://cdn.videohub.io/thumbs/pg_tutorial.jpg',
     1845, 24350, TRUE),

    (2, 1,
     'Docker + PostgreSQL: налаштування за 10 хвилин',
     'Швидкий старт: піднімаємо PostgreSQL у Docker-контейнері та підключаємо pgAdmin.',
     'https://cdn.videohub.io/videos/docker_pg.mp4',
     'https://cdn.videohub.io/thumbs/docker_pg.jpg',
     632, 8920, TRUE),

    -- Відео від каналу MusicVibes (user_id = 2)
    (3, 2,
     'Кавер "Місто весна" — живий виступ',
     'Живий виступ на фестивалі "Музика незалежності", літо 2026.',
     'https://cdn.videohub.io/videos/musicvibes_live.mp4',
     'https://cdn.videohub.io/thumbs/musicvibes_live.jpg',
     278, 15420, TRUE),

    -- Відео від каналу ScienceHubUA (user_id = 3)
    (4, 3,
     'Чому небо синє? Фізика атмосфери за 7 хвилин',
     'Розповідь про розсіювання Релея та чому небо має саме такий колір.',
     'https://cdn.videohub.io/videos/why_sky_blue.mp4',
     'https://cdn.videohub.io/thumbs/why_sky_blue.jpg',
     442, 51200, TRUE),

    (5, 3,
     'Як працюють чорні діри? Пояснення без формул',
     'Наукове, але доступне пояснення чорних дір, горизонту подій та сингулярності.',
     'https://cdn.videohub.io/videos/black_holes.mp4',
     'https://cdn.videohub.io/thumbs/black_holes.jpg',
     915, 102300, TRUE),

    -- Приватне відео (неопубліковане)
    (6, 1,
     'Чернетка: новий огляд Rust',
     'Незавершений огляд мови Rust. Не публікувати!',
     'https://cdn.videohub.io/videos/rust_draft.mp4',
     NULL,
     1200, 0, FALSE);

-- Перевірка
SELECT video_id, user_id, title, duration_seconds, views, is_public FROM video;


-- ============================================================================
-- 3. Коментарі (comment)
-- ============================================================================
-- Мікс: кореневі коментарі (parent_comment_id = NULL) та відповіді (parent_comment_id задан).
-- ============================================================================

INSERT INTO comment (comment_id, user_id, video_id, parent_comment_id, text)
VALUES
    -- Коментарі до відео 1 (PostgreSQL туторіал)
    (1, 4, 1, NULL,
     'Чудовий туторіал! Дуже зрозуміло пояснюєте JOIN-и. Дякую!'),

    (2, 5, 1, NULL,
     'На 12:34 є неточність — INNER JOIN не повертає рядки без відповідності, а ви сказали інакше.'),

    -- Відповідь на коментар 2 (вкладений коментар — parent_comment_id = 2)
    (3, 1, 1, 2,
     'Дякую, що помітили! Виправлю в описі під відео. Дійсно, INNER JOIN потребує відповідності з обох боків.'),

    -- Коментар до відео 4 (Чому небо синє?)
    (4, 4, 4, NULL,
     'Нарешті зрозуміла, чому небо синє! Дякую за просте пояснення.'),

    -- Коментар до відео 5 (Чорні діри)
    (5, 5, 5, NULL,
     'Це відео просто неймовірне. Горизонт подій — одна з найцікавіших концепцій у фізиці!'),

    -- Коментар до відео 3 (Музичний виступ)
    (6, 6, 3, NULL,
     'Дуже класний кавер! Коли буде новий трек?'),

    -- Ще одна відповідь (вкладений коментар до коментаря 5)
    (7, 3, 5, 5,
     'Дякую за підтримку! Наступне відео — про квантову заплутаність, готуйтеся!');

-- Перевірка
SELECT comment_id, user_id, video_id, parent_comment_id, LEFT(text, 60) AS text_preview FROM comment;


-- ============================================================================
-- 4. Вподобайки ("like")
-- ============================================================================
-- Мікс: лайки (is_like = TRUE) та дизлайки (is_like = FALSE).
-- Унікальне обмеження: один користувач — одна вподобайка на відео.
-- ============================================================================

INSERT INTO "like" (like_id, user_id, video_id, is_like)
VALUES
    -- Лайки до відео 1 (PostgreSQL туторіал)
    (1, 4, 1, TRUE),
    (2, 5, 1, TRUE),
    (3, 6, 1, TRUE),

    -- Дизлайк до відео 1 (хтось не задоволений)
    (4, 6, 2, FALSE),

    -- Лайки до відео 4 (Небо синє)
    (5, 4, 4, TRUE),
    (6, 5, 4, TRUE),

    -- Лайк до відео 5 (Чорні діри)
    (7, 5, 5, TRUE),

    -- Лайк та дизлайк до різних відео
    (8, 4, 3, TRUE),
    (9, 6, 5, FALSE);

-- Перевірка
SELECT like_id, user_id, video_id, is_like FROM "like";


-- ============================================================================
-- 5. Підписки (subscription)
-- ============================================================================
-- Асоціативна таблиця M:N. Складений PK (subscriber_id, channel_id).
-- CHECK забороняє підписку на самого себе (subscriber_id <> channel_id).
-- ============================================================================

INSERT INTO subscription (subscriber_id, channel_id)
VALUES
    -- Олена підписана на TechWithDeny та ScienceHubUA
    (4, 1),
    (4, 3),

    -- Андрій підписаний на TechWithDeny та MusicVibes
    (5, 1),
    (5, 2),

    -- Google-користувач підписаний на MusicVibes
    (6, 2),

    -- Канал ScienceHubUA підписаний на TechWithDeny (взаємна підписка каналів)
    (3, 1),

    -- Тех-канал підписаний на музичний (міжканальна підписка)
    (1, 2);

-- Перевірка
SELECT subscriber_id, channel_id FROM subscription;


-- ============================================================================
-- Приклади ПОРУШЕНЬ обмежень цілісності (навмисно закоментовані)
-- ============================================================================
-- Ці INSERT-и демонструють, як працюють обмеження. Вони НЕ виконуються,
-- але якщо розкоментувати — PostgreSQL поверне помилку.
-- ============================================================================

-- ---- 1. Порушення UNIQUE на "user".username ----
-- Користувач з нікнеймом 'TechWithDeny' вже існує (user_id = 1).
-- INSERT INTO "user" (user_id, username, email, password_hash, is_channel)
-- VALUES (10, 'TechWithDeny', 'duplicate@example.com', 'hash', FALSE);
-- Очікувана помилка: ERROR: duplicate key value violates unique constraint "uq_user_username"

-- ---- 2. Порушення UNIQUE на "user".email ----
-- Email 'techwithdeny@videohub.io' вже зайнятий.
-- INSERT INTO "user" (user_id, username, email, password_hash, is_channel)
-- VALUES (11, 'UniqueUser', 'techwithdeny@videohub.io', 'hash', FALSE);
-- Очікувана помилка: ERROR: duplicate key value violates unique constraint "uq_user_email"

-- ---- 3. Порушення UNIQUE(user_id, video_id) на "like" ----
-- Користувач 4 вже поставив лайк відео 1 (like_id = 1). Не можна додати ще раз.
-- INSERT INTO "like" (user_id, video_id, is_like)
-- VALUES (4, 1, FALSE);
-- Очікувана помилка: ERROR: duplicate key value violates unique constraint "uq_like_user_video"

-- ---- 4. Порушення CHECK (subscriber_id <> channel_id) на subscription ----
-- Користувач не може підписатися на самого себе.
-- INSERT INTO subscription (subscriber_id, channel_id)
-- VALUES (4, 4);
-- Очікувана помилка: ERROR: new row for relation "subscription" violates check constraint "chk_sub_no_self"

-- ---- 5. Порушення FK (video.user_id → "user") ----
-- Немає користувача з user_id = 999, тому відео не можна створити.
-- INSERT INTO video (video_id, user_id, title, video_url, duration_seconds)
-- VALUES (100, 999, 'Неможливе відео', 'https://example.com/v.mp4', 300);
-- Очікувана помилка: ERROR: insert or update on table "video" violates foreign key constraint "fk_video_user"

-- ---- 6. Порушення CHECK (duration_seconds > 0) на video ----
-- Тривалість має бути додатною, 0 — не допускається.
-- INSERT INTO video (video_id, user_id, title, video_url, duration_seconds)
-- VALUES (101, 1, 'Нульова тривалість', 'https://example.com/v2.mp4', 0);
-- Очікувана помилка: ERROR: new row for relation "video" violates check constraint "chk_video_duration"

-- ---- 7. Порушення NOT NULL (video.user_id) ----
-- user_id не може бути NULL, оскільки відео мусить мати власника.
-- INSERT INTO video (video_id, title, video_url, duration_seconds)
-- VALUES (102, 'Без власника', 'https://example.com/v3.mp4', 120);
-- Очікувана помилка: ERROR: null value in column "user_id" of relation "video" violates not null constraint

-- ---- 8. Порушення PRIMARY KEY на subscription ----
-- Пара (4, 1) вже існує — не можна додати ту саму підписку двічі.
-- INSERT INTO subscription (subscriber_id, channel_id)
-- VALUES (4, 1);
-- Очікувана помилка: ERROR: duplicate key value violates unique constraint "pk_subscription"
