-- =====================================================================
-- НОРМАЛІЗАЦІЯ video_denorm → 3NF
--
-- Етап 1 (1NF): Усунення неатомарних значень — список тегів розбивається
--   на окремі рядки у новій junction-таблиці video_tag.
--   Таблиця tag — довідник унікальних тегів.
--
-- Етап 2 (2NF): Усунення часткових залежностей від складеного ключа
--   (video_id, tag). Оскільки складений ключ руйнується після виділення
--   тегів, 2NF досягається автоматично — усі неключові атрибути залежать
--   від повного ключа video_id.
--
-- Етап 3 (3NF): Усунення транзитивних залежностей:
--   • video_id → user_id → username, email  (канал належить users)
--   • video_id → status_id → status_name    (статус — у lookup-таблиці)
--
-- Результат: п'ять таблиць у 3NF —
--   video, tag, video_tag, video_status, users (вже існувала).
-- =====================================================================


-- =====================================================================
-- ЕТАП 1: Досягнення 1NF — розділення тегів на окремі таблиці
-- =====================================================================

-- 1a. Довідник унікальних тегів (кожен тег — один рядок, атомарне значення)
CREATE TABLE tag (
    tag_id   SERIAL        PRIMARY KEY,
    name     VARCHAR(50)   NOT NULL UNIQUE
);

-- 1b. Junction-таблиця для зв'язку M:N «відео ↔ тег»
--     Кожний рядок — одна атомарна пара (відео, тег).
CREATE TABLE video_tag (
    video_id  INTEGER  NOT NULL,
    tag_id    INTEGER  NOT NULL,
    PRIMARY KEY (video_id, tag_id)
);


-- =====================================================================
-- ЕТАП 3: Досягнення 3NF — lookup-таблиця статусів
-- (Створюємо перед ALTER TABLE, бо відео потребуватиме FK на неї)
-- =====================================================================

CREATE TABLE video_status (
    status_id  SERIAL        PRIMARY KEY,
    name       VARCHAR(20)   NOT NULL UNIQUE
);

INSERT INTO video_status (name) VALUES ('публічне'), ('приватне'), ('приховане');


-- =====================================================================
-- ЕТАП 3 (продовження): ALTER TABLE video —
--   видалення транзитивних та продубльованих стовпців,
--   додавання зовнішніх ключів
-- =====================================================================

-- Крок 1. Видаляємо дубльований текстовий статус (транзитивна залежність):
--        video_id → status_id → status_name
--        Залишаємо status_id як FK на video_status.
ALTER TABLE video DROP COLUMN IF EXISTS status_name;

-- Крок 2. Видаляємо продубльовані дані каналу (транзитивна залежність):
--        video_id → user_id → username, email
--        Інформація про канал зберігається в таблиці users.
ALTER TABLE video DROP COLUMN IF EXISTS username;
ALTER TABLE video DROP COLUMN IF EXISTS email;

-- Крок 3. Видаляємо колонку tags — список тегів через кому (порушення 1NF).
--        Теги тепер зберігаються в video_tag + tag.
ALTER TABLE video DROP COLUMN IF EXISTS tags;

-- Крок 4. Видаляємо колонку tag — частину складеного ключа video_denorm.
--        Теги нормалізовані через junction-таблицю video_tag.
ALTER TABLE video DROP COLUMN IF EXISTS tag;

-- Крок 5. Додаємо зовнішній ключ на таблицю статусів.
ALTER TABLE video
    ADD CONSTRAINT fk_video_status
    FOREIGN KEY (status_id) REFERENCES video_status(status_id);

-- Крок 6. Додаємо зовнішні ключі для junction-таблиці video_tag.
ALTER TABLE video_tag
    ADD CONSTRAINT fk_video_tag_video
    FOREIGN KEY (video_id) REFERENCES video(video_id) ON DELETE CASCADE;

ALTER TABLE video_tag
    ADD CONSTRAINT fk_video_tag_tag
    FOREIGN KEY (tag_id) REFERENCES tag(tag_id) ON DELETE CASCADE;


-- =====================================================================
-- Заповнення нових таблиць даними з video_denorm
-- =====================================================================

-- Довідник тегів (унікальні значення)
INSERT INTO tag (name)
SELECT DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(tags, ',')))
FROM (SELECT DISTINCT tags FROM video_denorm) AS src
ORDER BY 1;

-- Зв'язки відео ↔ тег
INSERT INTO video_tag (video_id, tag_id)
SELECT DISTINCT d.video_id, t.tag_id
FROM video_denorm d,
     LATERAL (
         SELECT TRIM(UNNEST(STRING_TO_ARRAY(d.tags, ','))) AS tag_name
     ) AS exploded
JOIN tag t ON t.name = exploded.tag_name
ORDER BY d.video_id, t.tag_id;

-- Статуси вже заповнені вище (INSERT INTO video_status).


-- =====================================================================
-- ФІНАЛЬНА НОРМАЛІЗОВАНА СХЕМА (3NF) — CREATE TABLE
-- Повні визначення всіх задіяних таблиць після нормалізації
-- =====================================================================

-- Таблиця статусів відео (lookup)
CREATE TABLE video_status (
    status_id  SERIAL        PRIMARY KEY,
    name       VARCHAR(20)   NOT NULL UNIQUE
);

-- Основна таблиця відео (без продубльованих даних каналу та статусу)
CREATE TABLE video (
    video_id          BIGSERIAL     PRIMARY KEY,
    user_id           BIGINT        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title             VARCHAR(255)  NOT NULL,
    description       TEXT,
    video_url         TEXT          NOT NULL,
    thumbnail_url     TEXT,
    duration_seconds  INTEGER       NOT NULL CHECK (duration_seconds > 0),
    views             INTEGER       NOT NULL DEFAULT 0 CHECK (views >= 0),
    status_id         INTEGER       NOT NULL REFERENCES video_status(status_id),
    is_public         BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Довідник тегів (кожен тег — один рядок)
CREATE TABLE tag (
    tag_id   SERIAL        PRIMARY KEY,
    name     VARCHAR(50)   NOT NULL UNIQUE
);

-- Junction-таблиця M:N «відео ↔ тег»
CREATE TABLE video_tag (
    video_id  BIGINT   NOT NULL REFERENCES video(video_id)   ON DELETE CASCADE,
    tag_id    INTEGER  NOT NULL REFERENCES tag(tag_id)       ON DELETE CASCADE,
    PRIMARY KEY (video_id, tag_id)
);
