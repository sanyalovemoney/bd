# VideoHub — канонічна схема (спільна для всіх лаб)

**Проєкт:** VideoHub — відеохостинг-платформа (аналог YouTube).
GitHub: https://github.com/ezpectus/VideoHub

## 5 сутностей

### User (користувач / канал)
| стовпець | тип | опис |
|---|---|---|
| user_id | BIGSERIAL PK | унікальний ідентифікатор |
| username | VARCHAR(30) NOT NULL UNIQUE | нікнейм |
| email | VARCHAR(255) NOT NULL UNIQUE | email |
| password_hash | VARCHAR(255) | хеш пароля; NULL якщо авторизується лише через Google |
| google_id | VARCHAR(255) UNIQUE | id Google OAuth; NULL для парольної авт. |
| avatar_url | TEXT | URL аватара |
| bio | TEXT | опис каналу |
| is_channel | BOOLEAN NOT NULL DEFAULT FALSE | чи має канал (можна завантажувати відео) |
| created_at | TIMESTAMPTZ NOT NULL DEFAULT NOW() | дата реєстрації |

### Video (відео)
| стовпець | тип | опис |
|---|---|---|
| video_id | BIGSERIAL PK | унікальний ідентифікатор |
| user_id | BIGINT NOT NULL FK→User ON DELETE CASCADE | власник (канал) |
| title | VARCHAR(255) NOT NULL | заголовок |
| description | TEXT | опис |
| video_url | TEXT NOT NULL | URL файлу відео |
| thumbnail_url | TEXT | URL обкладинки |
| duration_seconds | INTEGER NOT NULL CHECK (>0) | тривалість |
| views | INTEGER NOT NULL DEFAULT 0 CHECK (>=0) | перегляди |
| is_public | BOOLEAN NOT NULL DEFAULT TRUE | публічне/приватне |
| created_at | TIMESTAMPTZ NOT NULL DEFAULT NOW() | дата завантаження |

### Comment (коментар)
| стовпець | тип | опис |
|---|---|---|
| comment_id | BIGSERIAL PK | унікальний ідентифікатор |
| user_id | BIGINT NOT NULL FK→User ON DELETE CASCADE | автор |
| video_id | BIGINT NOT NULL FK→Video ON DELETE CASCADE | відео |
| parent_comment_id | BIGINT FK→Comment ON DELETE CASCADE | батьківський коментар (відповідь); NULL = кореневий |
| text | TEXT NOT NULL | текст |
| created_at | TIMESTAMPTZ NOT NULL DEFAULT NOW() | дата |

### Like (вподобайка / дизлайк)
| стовпець | тип | опис |
|---|---|---|
| like_id | BIGSERIAL PK | сурогатний ключ |
| user_id | BIGINT NOT NULL FK→User ON DELETE CASCADE | хто лайкнув |
| video_id | BIGINT NOT NULL FK→Video ON DELETE CASCADE | відео |
| is_like | BOOLEAN NOT NULL | TRUE=лайк, FALSE=дизлайк |
| created_at | TIMESTAMPTZ NOT NULL DEFAULT NOW() | дата |
| UNIQUE(user_id, video_id) | | один юзер — один вподобайка на відео |

### Subscription (підписка) — M:N само-посилання на User
| стовпець | тип | опис |
|---|---|---|
| subscriber_id | BIGINT FK→User ON DELETE CASCADE | хто підписується |
| channel_id | BIGINT FK→User ON DELETE CASCADE | на кого підписується |
| created_at | TIMESTAMPTZ NOT NULL DEFAULT NOW() | дата |
| PRIMARY KEY(subscriber_id, channel_id) | | складений ключ |
| CHECK(subscriber_id <> channel_id) | | не можна підписатись на себе |

## 4 зв'язки
1. **User → Video (1:N)** — один канал має багато відео; FK `video.user_id`. При видаленні User → відео видаляються (CASCADE).
2. **User → Comment ← Video (1:N + 1:N)** — Comment має два FK: на автора (User) і на відео (Video). 1:N з обох боків.
3. **User → Like ← Video (1:N + 1:N)** — аналогічно Comment, з UNIQUE(user_id, video_id) щоб уникнути дублів.
4. **User → Subscription ← User (M:N)** — асоціативна таблиця зі складеним PK; само-посилання.

## Розширена/нормалізована частина (Lab 5)
У Lab 5 вводимо lookup-таблицю **video_status** (status_id PK, name) та/або **role**, щоб усунути транзитивну залежність (is_public як текстовий статус «public/private/unlisted» замінити на FK→video_status). Див. окремий звіт Lab 5.

## Prisma (Lab 6) — додаємо модель **Playlist** + **PlaylistVideo** (M:N відео↔плейлист), а також додаємо поле `is_verified BOOLEAN` до User.
