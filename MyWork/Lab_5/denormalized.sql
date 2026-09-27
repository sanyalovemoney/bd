-- =====================================================================
-- DENORMALIZED TABLE: video_denorm
-- Мета: продемонструвати проблеми ненормалізованої схеми
--
-- Порушення:
--   1NF — теги зберігаються як список, розділений комами (не атомарне значення)
--   2NF — складений первинний ключ (video_id, tag);
--         неключові атрибути залежать лише від video_id (часткова залежність)
--   3NF — транзитивні залежності:
--         video_id → user_id → username, email
--         video_id → status_id → status_name
-- =====================================================================

DROP TABLE IF EXISTS video_denorm;

CREATE TABLE video_denorm (
    video_id          INTEGER       NOT NULL,
    tag               VARCHAR(50)   NOT NULL,      -- один з тегів відео (частина складеного ключа)
    title             VARCHAR(255)  NOT NULL,
    description       TEXT,
    video_url         TEXT          NOT NULL,
    thumbnail_url     TEXT,
    duration_seconds  INTEGER       NOT NULL CHECK (duration_seconds > 0),
    views             INTEGER       NOT NULL DEFAULT 0 CHECK (views >= 0),
    user_id           INTEGER       NOT NULL,       -- FK на users (канал-власник)
    username          VARCHAR(30)   NOT NULL,       -- ДУБЛЮВАННЯ: залежить від user_id, не від ключа
    email             VARCHAR(255)  NOT NULL,       -- ДУБЛЮВАННЯ: залежить від user_id, не від ключа
    status_id         INTEGER       NOT NULL,       -- 1=public, 2=private, 3=unlisted
    status_name       VARCHAR(20)   NOT NULL,       -- ДУБЛЮВАННЯ: залежить від status_id (транзитивно)
    tags              TEXT          NOT NULL,       -- ПОРУШЕННЯ 1NF: список тегів через кому
    PRIMARY KEY (video_id, tag)
);

-- =====================================================================
-- Приклад даних:
--   • Канал TechReview (user_id=1) — 3 відео; username/email повторюються у кожному рядку
--   • Канал GameZone    (user_id=2) — 2 відео
--   • Канал MusicVibes  (user_id=3) — 1 відео
--   • Теги зберігаються І як окремий рядок (часткова ключова колонка tag),
--     І як повний список у колонці tags (дублювання + порушення атомарності)
--   • status_name («публічне» / «приватне» / «приховане») повторюється
--     у кожному рядку замість того щоб зберігатись у lookup-таблиці
-- =====================================================================

INSERT INTO video_denorm VALUES
-- user_id=1 (TechReview), status_id=1 (public)
(1, 'tech',
 'Огляд iPhone 16 Pro',
 'Детальний огляд нового iPhone 16 Pro від Apple',
 'https://videohub.com/v/001.mp4',
 'https://videohub.com/th/001.jpg',
 720, 15000, 1,
 'TechReview', 'techreview@videohub.com',
 1, 'публічне',
 'tech,apple,iphone,огляд'),

(1, 'apple',
 'Огляд iPhone 16 Pro',
 'Детальний огляд нового iPhone 16 Pro від Apple',
 'https://videohub.com/v/001.mp4',
 'https://videohub.com/th/001.jpg',
 720, 15000, 1,
 'TechReview', 'techreview@videohub.com',
 1, 'публічне',
 'tech,apple,iphone,огляд'),

(1, 'iphone',
 'Огляд iPhone 16 Pro',
 'Детальний огляд нового iPhone 16 Pro від Apple',
 'https://videohub.com/v/001.mp4',
 'https://videohub.com/th/001.jpg',
 720, 15000, 1,
 'TechReview', 'techreview@videohub.com',
 1, 'публічне',
 'tech,apple,iphone,огляд'),

-- user_id=1 (TechReview), status_id=1 (public)
(2, 'tech',
 'Порівняння Samsung Galaxy S25',
 'Порівняння Samsung Galaxy S25 з конкурентами',
 'https://videohub.com/v/002.mp4',
 'https://videohub.com/th/002.jpg',
 900, 8500, 1,
 'TechReview', 'techreview@videohub.com',
 1, 'публічне',
 'tech,samsung,galaxy'),

(2, 'samsung',
 'Порівняння Samsung Galaxy S25',
 'Порівняння Samsung Galaxy S25 з конкурентами',
 'https://videohub.com/v/002.mp4',
 'https://videohub.com/th/002.jpg',
 900, 8500, 1,
 'TechReview', 'techreview@videohub.com',
 1, 'публічне',
 'tech,samsung,galaxy'),

-- user_id=1 (TechReview), status_id=3 (unlisted)
(3, 'tech',
 'MacBook Pro M4 — перші враження',
 'Перші враження від нового MacBook Pro на чіпі M4',
 'https://videohub.com/v/003.mp4',
 'https://videohub.com/th/003.jpg',
 1200, 320, 1,
 'TechReview', 'techreview@videohub.com',
 3, 'приховане',
 'tech,apple,macbook'),

-- user_id=2 (GameZone), status_id=1 (public)
(4, 'gaming',
 'Проходження GTA VI — Місія 1',
 'Перша місія в GTA VI, повне проходження без підказок',
 'https://videohub.com/v/004.mp4',
 'https://videohub.com/th/004.jpg',
 3600, 52000, 2,
 'GameZone', 'gamezone@videohub.com',
 1, 'публічне',
 'gaming,gta,проходження'),

(4, 'gta',
 'Проходження GTA VI — Місія 1',
 'Перша місія в GTA VI, повне проходження без підказок',
 'https://videohub.com/v/004.mp4',
 'https://videohub.com/th/004.jpg',
 3600, 52000, 2,
 'GameZone', 'gamezone@videohub.com',
 1, 'публічне',
 'gaming,gta,проходження'),

-- user_id=2 (GameZone), status_id=2 (private)
(5, 'gaming',
 'Стрім: Elden Ring DLC',
 'Приватний стрім для друзів — Elden Ring DLC',
 'https://videohub.com/v/005.mp4',
 'https://videohub.com/th/005.jpg',
 5400, 150, 2,
 'GameZone', 'gamezone@videohub.com',
 2, 'приватне',
 'gaming,eldenring,stream'),

-- user_id=3 (MusicVibes), status_id=1 (public)
(6, 'music',
 'Топ-10 пісень 2025 року',
 'Мій рейтинг найкращих пісень 2025 року',
 'https://videohub.com/v/006.mp4',
 'https://videohub.com/th/006.jpg',
 480, 23000, 3,
 'MusicVibes', 'musicvibes@videohub.com',
 1, 'публічне',
 'music,top,2025');
