-- ============================================================================
-- VideoHub — схема бази даних (PostgreSQL DDL)
-- Лабораторна робота №2
-- Автор: Машута Олександр, ІМ-051
-- ============================================================================

-- Підключаємо розширення citext для регістронезалежних рядків (email, username).
-- Це дозволяє уникнути дублікатів на кшталт "User@mail.com" vs "user@mail.com".
CREATE EXTENSION IF NOT EXISTS citext;

-- ============================================================================
-- Таблиця: "user"
-- Опис: зберігає всіх зареєстрованих користувачів платформи VideoHub.
-- Кожен користувач може бути або звичайним глядачем, або каналом (is_channel = TRUE),
-- який має право завантажувати відео. Передбачено два способи автентифікації:
-- парольна (password_hash) та Google OAuth (google_id). Якщо користувач
-- входить лише через Google, password_hash може бути NULL.
-- ============================================================================
CREATE TABLE "user" (
    -- Унікальний ідентифікатор користувача (автоінкрементний BIGINT)
    user_id         BIGSERIAL
                    CONSTRAINT pk_user PRIMARY KEY,

    -- Нікнейм користувача (30 символів максимум, унікальний, обов'язковий)
    username        CITEXT(30)
                    CONSTRAINT uq_user_username UNIQUE
                    CONSTRAINT nn_user_username NOT NULL,

    -- Електронна пошта користувача (255 символів, унікальна, обов'язкова)
    email           CITEXT(255)
                    CONSTRAINT uq_user_email UNIQUE
                    CONSTRAINT nn_user_email NOT NULL,

    -- Хеш пароля. Може бути NULL, якщо користувач автентифікується лише через Google OAuth.
    password_hash   VARCHAR(255),

    -- Ідентифікатор Google OAuth-акаунта. Унікальний, може бути NULL для парольної автентифікації.
    google_id       VARCHAR(255)
                    CONSTRAINT uq_user_google_id UNIQUE,

    -- URL аватара користувача (необов'язковий)
    avatar_url      TEXT,

    -- Опис / біографія каналу (необов'язкове)
    bio             TEXT,

    -- Чи є користувач каналом (може завантажувати відео). За замовчуванням — FALSE (звичайний глядач).
    is_channel      BOOLEAN
                    CONSTRAINT nn_user_is_channel NOT NULL
                    DEFAULT FALSE,

    -- Дата та час реєстрації користувача. За замовчуванням — поточний момент.
    created_at      TIMESTAMPTZ
                    CONSTRAINT nn_user_created_at NOT NULL
                    DEFAULT NOW()
);

-- Індекс для прискорення пошуку за email (хоча UNIQUE вже створює B-tree індекс,
-- додатковий індекс тут не потрібен, але додамо для створення каналів)
CREATE INDEX idx_user_is_channel ON "user" (is_channel);

-- ============================================================================
-- Таблиця: "video"
-- Опис: зберігає відеозаписи, завантажені каналами. Кожне відео належить
-- рівно одному користувачеві-каналу (FK→user). При видаленні каналу всі його
-- відео видаляються автоматично (ON DELETE CASCADE).
-- ============================================================================
CREATE TABLE video (
    -- Унікальний ідентифікатор відео (автоінкрементний BIGINT)
    video_id            BIGSERIAL
                        CONSTRAINT pk_video PRIMARY KEY,

    -- Власник відео (канал). Зовнішній ключ до таблиці "user".
    -- При видаленні користувача відео видаляються каскадно.
    user_id             BIGINT
                        CONSTRAINT nn_video_user_id NOT NULL
                        CONSTRAINT fk_video_user FOREIGN KEY REFERENCES "user" (user_id)
                            ON DELETE CASCADE,

    -- Заголовок відео (обов'язковий, до 255 символів)
    title               VARCHAR(255)
                        CONSTRAINT nn_video_title NOT NULL,

    -- Опис відео (необов'язковий, довгий текст)
    description         TEXT,

    -- URL відеофайлу (обов'язковий)
    video_url           TEXT
                        CONSTRAINT nn_video_url NOT NULL,

    -- URL обкладинки/прев'ю (необов'язковий)
    thumbnail_url       TEXT,

    -- Тривалість відео в секундах. Має бути додатною (>0).
    duration_seconds    INTEGER
                        CONSTRAINT nn_video_duration NOT NULL
                        CONSTRAINT chk_video_duration CHECK (duration_seconds > 0),

    -- Кількість переглядів. За замовчуванням 0, не може бути від'ємною.
    views               INTEGER
                        CONSTRAINT nn_video_views NOT NULL
                        CONSTRAINT chk_video_views CHECK (views >= 0)
                        DEFAULT 0,

    -- Чи є відео публічним. За замовчуванням — TRUE.
    is_public           BOOLEAN
                        CONSTRAINT nn_video_is_public NOT NULL
                        DEFAULT TRUE,

    -- Дата та час завантаження відео. За замовчуванням — поточний момент.
    created_at          TIMESTAMPTZ
                        CONSTRAINT nn_video_created_at NOT NULL
                        DEFAULT NOW()
);

-- Індекс для швидкого пошуку відео за каналом
CREATE INDEX idx_video_user ON video (user_id);

-- Індекс для пошуку публічних відео
CREATE INDEX idx_video_public ON video (is_public) WHERE is_public = TRUE;

-- ============================================================================
-- Таблиця: "comment"
-- Опис: коментарі користувачів до відео. Підтримує вкладеність (відповіді)
-- через self-referencing FK parent_comment_id. При видаленні батьківського
-- коментаря всі відповіді видаляються каскадно.
-- ============================================================================
CREATE TABLE comment (
    -- Унікальний ідентифікатор коментаря (автоінкрементний BIGINT)
    comment_id          BIGSERIAL
                        CONSTRAINT pk_comment PRIMARY KEY,

    -- Автор коментаря (FK→user). При видаленні користувача коментарі видаляються каскадно.
    user_id             BIGINT
                        CONSTRAINT nn_comment_user_id NOT NULL
                        CONSTRAINT fk_comment_user FOREIGN KEY REFERENCES "user" (user_id)
                            ON DELETE CASCADE,

    -- Відео, до якого залишено коментар (FK→video). При видаленні відео коментарі видаляються каскадно.
    video_id            BIGINT
                        CONSTRAINT nn_comment_video_id NOT NULL
                        CONSTRAINT fk_comment_video FOREIGN KEY REFERENCES video (video_id)
                            ON DELETE CASCADE,

    -- Батьківський коментар (NULL = кореневий коментар, не відповідь).
    -- Self-referencing FK: при видаленні батьківського коментаря відповідь теж видаляється.
    parent_comment_id   BIGINT
                        CONSTRAINT fk_comment_parent FOREIGN KEY REFERENCES comment (comment_id)
                            ON DELETE CASCADE,

    -- Текст коментаря (обов'язковий)
    text                TEXT
                        CONSTRAINT nn_comment_text NOT NULL,

    -- Дата та час створення коментаря
    created_at          TIMESTAMPTZ
                        CONSTRAINT nn_comment_created_at NOT NULL
                        DEFAULT NOW()
);

-- Індекс для пошуку коментарів за відео
CREATE INDEX idx_comment_video ON comment (video_id);

-- Індекс для пошуку відповідей (коментарів із батьківським коментарем)
CREATE INDEX idx_comment_parent ON comment (parent_comment_id);

-- ============================================================================
-- Таблиця: "like"
-- Опис: вподобайки (лайки/дизлайки) користувачів до відео. Кожен користувач
-- може поставити лише одну оцінку (лайк або дизлайк) на кожне відео — це
-- забезпечується унікальним обмеженням UNIQUE(user_id, video_id).
-- ============================================================================
CREATE TABLE "like" (
    -- Сурогатний первинний ключ (автоінкрементний BIGINT)
    like_id         BIGSERIAL
                    CONSTRAINT pk_like PRIMARY KEY,

    -- Користувач, який поставив вподобайку (FK→user)
    user_id         BIGINT
                    CONSTRAINT nn_like_user_id NOT NULL
                    CONSTRAINT fk_like_user FOREIGN KEY REFERENCES "user" (user_id)
                        ON DELETE CASCADE,

    -- Відео, яке отримало вподобайку (FK→video)
    video_id        BIGINT
                    CONSTRAINT nn_like_video_id NOT NULL
                    CONSTRAINT fk_like_video FOREIGN KEY REFERENCES video (video_id)
                        ON DELETE CASCADE,

    -- TRUE = лайк, FALSE = дизлайк (обов'язкове)
    is_like         BOOLEAN
                    CONSTRAINT nn_like_is_like NOT NULL,

    -- Дата та час створення вподобайки
    created_at      TIMESTAMPTZ
                    CONSTRAINT nn_like_created_at NOT NULL
                    DEFAULT NOW(),

    -- Кожен користувач може поставити лише одну вподобайку на кожне відео
    CONSTRAINT uq_like_user_video UNIQUE (user_id, video_id)
);

-- Індекс для швидкого підрахунку лайків/дизлайків відео
CREATE INDEX idx_like_video ON "like" (video_id);

-- ============================================================================
-- Таблиця: "subscription"
-- Опис: підписки користувачів на канали. Це асоціативна таблиця для зв'язку
-- M:N між користувачами (self-referencing). Складений первинний ключ
-- (subscriber_id, channel_id) гарантує, що один користувач не може підписатися
-- на один канал двічі. CHECK обмеження забороняє підписку на самого себе.
-- ============================================================================
CREATE TABLE subscription (
    -- Хто підписується (FK→user). При видаленні користувача підписки видаляються каскадно.
    subscriber_id   BIGINT
                    CONSTRAINT nn_sub_subscriber NOT NULL
                    CONSTRAINT fk_sub_subscriber FOREIGN KEY REFERENCES "user" (user_id)
                        ON DELETE CASCADE,

    -- На кого підписується (FK→user). При видаленні каналу підписки на нього видаляються каскадно.
    channel_id      BIGINT
                    CONSTRAINT nn_sub_channel NOT NULL
                    CONSTRAINT fk_sub_channel FOREIGN KEY REFERENCES "user" (user_id)
                        ON DELETE CASCADE,

    -- Дата та час підписки
    created_at      TIMESTAMPTZ
                    CONSTRAINT nn_sub_created_at NOT NULL
                    DEFAULT NOW(),

    -- Складений первинний ключ: одна підписка на пару (підписник, канал)
    CONSTRAINT pk_subscription PRIMARY KEY (subscriber_id, channel_id),

    -- Заборона підписки на самого себе
    CONSTRAINT chk_sub_no_self CHECK (subscriber_id <> channel_id)
);

-- Індекс для швидкого пошуку підписників каналу
CREATE INDEX idx_sub_channel ON subscription (channel_id);
