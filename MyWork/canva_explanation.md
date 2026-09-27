# Огляд всіх 6 лаб

## Коротко

Проєкт **VideoHub** — відеохостинг-платформа (аналог YouTube). 5 сутностей: User, Video, Comment, Like, Subscription. 4 зв'язки між ними. Пройшли повний цикл: від ER-діаграми до ORM з міграціями.

## Таблиця лаб

| Лаба | Тема | Статус | Дата |
|------|------|--------|------|
| Lab 1 | ER-діаграма | ✅ | 02.09 |
| Lab 2 | DDL (CREATE TABLE) | ✅ | 03.09 |
| Lab 3 | OLTP (SELECT, INSERT, UPDATE, DELETE) | ✅ | 05.09 |
| Lab 4 | OLAP (JOIN, агрегації, GROUP BY, HAVING) | ✅ | 09.09 |
| Lab 5 | Нормалізація (1NF, 2NF, 3NF) | ✅ | 12.09 |
| Lab 6 | Prisma ORM та міграції | ✅ | 16.09 |

## Опис проєкту

**VideoHub** — це платформа для завантаження та перегляду відео. Користувачі можуть створювати канали, завантажувати відео, залишати коментарі, ставити лайки/дизлайки та підписуватись на інші канали.

**5 сутностей:**
- **User** — користувач або канал
- **Video** — відео, належить користувачу
- **Comment** — коментар до відео, може бути відповіддю на інший коментар
- **Like** — лайк або дизлайк відео
- **Subscription** — підписка одного користувача на іншого (M:N)

**4 зв'язки:**
- User → Video (1:N) — канал має багато відео
- User → Comment ← Video (1:N + 1:N) — коментар має автора і відео
- User → Like ← Video (1:N + 1:N) — лайк має користувача і відео
- User → Subscription ← User (M:N) — підписки між користувачами

## Термінологія

- **Сутність** — об'єкт реального світу в БД. EXAMPLE: User, Video — це сутності.
- **Зв'язок** — відношення між сутностями. EXAMPLE: User завантажує Video — зв'язок 1:N.
- **Схема БД** — структура таблиць, зв'язків та обмежень. EXAMPLE: наша схема має 5 таблиців.

## Що показати преподу

- ER-діаграму (скріншот з draw.io або Mermaid)
- Таблицю з 6 лабами — показати що все зроблено
- Загальний опис проєкту — 5 сутностей, 4 зв'язки

---

# Lab 1: ER-діаграма

## Коротко

ER-діаграма — це візуальна схема бази даних. Показує сутності (прямокутники), атрибути (овали) та зв'язки (ромби). Ми намалювали 5 сутностей та 4 зв'язки для VideoHub.

## Термінологія

- **Сутність (Entity)** — об'єкт про який зберігаємо дані. EXAMPLE: `User` — зберігаємо user_id, username, email. Кожна сутність = окрема таблиця.

- **Атрибут** — властивість сутності. EXAMPLE: у `Video` атрибути: title, description, duration_seconds, views.

- **Первинний ключ (PK, Primary Key)** — унікальний ідентифікатор запису. EXAMPLE: `user_id BIGSERIAL` в таблиці User. Кожен користувач має свій унікальний номер.

- **Зовнішній ключ (FK, Foreign Key)** — посилання на іншу таблицю. EXAMPLE: `video.user_id → User.user_id` — відео посилається на свого власника.

- **Кардинальність 1:N** — одному запису відповідає багато записів. EXAMPLE: один User має багато Video. Але кожне Video має тільки одного User.

- **Кардинальність M:N** — багатосторонній зв'язок. EXAMPLE: User підписується на User — один може підписатись на багатьох, і на одного можуть підписатись багато. Реалізуємо через асоціативну таблицю `Subscription`.

- **Асоціативна сутність** — таблиця для M:N зв'язку. EXAMPLE: `Subscription(subscriber_id, channel_id)` — з'єднує двох користувачів. Має складений PK з обох FK.

- **Обмеження (Constraint)** — правило для даних. EXAMPLE: `CHECK(subscriber_id <> channel_id)` — не можна підписатись на себе.

## Приклади з VideoHub

```
User (1) ──── (N) Video        → один канал, багато відео
User (1) ──── (N) Comment      → один автор, багато коментарів
Video (1) ─── (N) Comment      → одне відео, багато коментарів
User (1) ──── (N) Like         → один юзер, багато лайків
Video (1) ─── (N) Like         → одне відео, багато лайків
User (M) ──── (N) Subscription → M:N через асоціативну таблицю
```

## Що показати преподу

- ER-діаграму (скріншот з draw.io або Mermaid)
- Пояснити чому Subscription — це асоціативна сутність (M:N)
- Показати кардинальність 1:N на прикладі User→Video
- Скріншот діаграми з `Lab1/screenshots/`

---

# Lab 2: DDL — CREATE TABLE

## Коротко

DDL (Data Definition Language) — це команди для створення структури БД. Ми створили 5 таблиць з правильними типами даних, первинними ключами, зовнішніми ключами та обмеженнями.

## Термінологія

- **DDL (Data Definition Language)** — мову опису структури даних. Основні команди: CREATE TABLE, ALTER TABLE, DROP TABLE.

- **CREATE TABLE** — команда створення таблиці. EXAMPLE:
```sql
CREATE TABLE "user" (
    user_id BIGSERIAL PRIMARY KEY,
    username VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    is_channel BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

- **BIGSERIAL** — автоінкрементний лічильник (8 байт). EXAMPLE: `user_id BIGSERIAL` — при кожному INSERT автоматично збільшується на 1.

- **VARCHAR(n)** — рядок фіксованої максимальної довжини. EXAMPLE: `username VARCHAR(30)` — нікнейм до 30 символів.

- **TEXT** — рядок без обмеження довжини. EXAMPLE: `description TEXT` — опис відео може бути дуже довгим.

- **TIMESTAMPTZ** — дата й час з часовою зоною. EXAMPLE: `created_at TIMESTAMPTZ DEFAULT NOW()` — автоматично записує момент створення.

- **BOOLEAN** — true/false. EXAMPLE: `is_public BOOLEAN DEFAULT TRUE` — відео публічне за замовчуванням.

- **INTEGER** — ціле число. EXAMPLE: `views INTEGER DEFAULT 0` — лічильник переглядів.

- **NOT NULL** — заборона порожніх значень. EXAMPLE: `title VARCHAR(255) NOT NULL` — відео не може бути без назви.

- **UNIQUE** — унікальність. EXAMPLE: `email VARCHAR(255) UNIQUE` — два користувачі не можуть мати однаковий email.

- **CHECK** — перевірка умови. EXAMPLE: `duration_seconds INTEGER CHECK (duration_seconds > 0)` — тривалість має бути додатною.

- **DEFAULT** — значення за замовчуванням. EXAMPLE: `views INTEGER DEFAULT 0` — нове відео має 0 переглядів.

- **ON DELETE CASCADE** — при видаленні батька видаляються діти. EXAMPLE: `video.user_id REFERENCES "user"(user_id) ON DELETE CASCADE` — видалили канал → всі його відео теж видалились.

## Порядок створення таблиць

Створюємо таблиці в порядку залежності (батьки перші):
1. `"user"` — не залежить ні від кого
2. `"video"` — залежить від User (FK user_id)
3. `"comment"` — залежить від User + Video + self-reference
4. `"like"` — залежить від User + Video
5. `"subscription"` — залежить від User (двічі)

## Приклад створення Video

```sql
CREATE TABLE video (
    video_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url TEXT NOT NULL,
    duration_seconds INTEGER NOT NULL CHECK (duration_seconds > 0),
    views INTEGER NOT NULL DEFAULT 0 CHECK (views >= 0),
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Що показати преподу

- Скріншот pgAdmin з виконаним CREATE TABLE (без помилок)
- Скріншот SELECT * для кожної з 5 таблиць
- Пояснити порядок створення (чому User перший)
- Показати ON DELETE CASCADE на прикладі Video

---

# Lab 3: OLTP — SELECT, INSERT, UPDATE, DELETE

## Коротко

OLTP (Online Transaction Processing) — це операції з даними: вибірка, додавання, зміна, видалення. Використовуємо DML (Data Manipulation Language) команди.

## Термінологія

- **OLTP (Online Transaction Processing)** — операційна обробка транзакцій. Це звичайні операції з БД: прочитати, додати, змінити, видалити. EXAMPLE: користувач зайшов → побачив відео → поставив лайк — це 3 OLTP-операції.

- **DML (Data Manipulation Language)** — мову маніпуляції даними. Команди: SELECT, INSERT, UPDATE, DELETE.

- **SELECT** — вибірка даних. EXAMPLE:
```sql
SELECT title, views FROM video
WHERE user_id = 1
ORDER BY views DESC;
```

- **WHERE** — фільтр записів. EXAMPLE: `WHERE views > 1000` — тільки відео з більше ніж 1000 переглядів.

- **ORDER BY** — сортування результату. EXAMPLE: `ORDER BY created_at DESC` — спочатку найновіші.

- **LIKE** — пошук по шаблону. EXAMPLE:
```sql
SELECT * FROM video WHERE title LIKE '%SQL%';
```
Знайти всі відео де в назві є "SQL". `%` — будь-яка кількість будь-яких символів.

- **INSERT** — додавання нового запису. EXAMPLE:
```sql
INSERT INTO video (user_id, title, video_url, duration_seconds)
VALUES (1, 'Мій перший ролик', 'https://cdn.videohub/v1.mp4', 120);
```

- **UPDATE / SET** — зміна існуючих даних. EXAMPLE:
```sql
UPDATE video SET views = views + 1 WHERE video_id = 5;
```

- **DELETE** — видалення записів. EXAMPLE:
```sql
DELETE FROM comment WHERE comment_id = 42;
```

## УВАГА: WHERE без UPDATE/DELETE

Якщо написати `UPDATE video SET views = 100;` без WHERE — зміниться ВСЕ відео в базі! Те саме з DELETE. Завжди перевіряй WHERE.

## Приклади з VideoHub

```sql
-- 1. Знайти всі відео користувача
SELECT title, views, created_at FROM video
WHERE user_id = 3 ORDER BY created_at DESC;

-- 2. Додати коментар
INSERT INTO comment (user_id, video_id, text)
VALUES (2, 5, 'Чудове відео про SQL!');

-- 3. Збільшити перегляди
UPDATE video SET views = views + 1 WHERE video_id = 5;

-- 4. Видалити спам-коментар
DELETE FROM comment WHERE comment_id = 99;

-- 5. Пошук відео по назві
SELECT * FROM video WHERE title LIKE '%PostgreSQL%';
```

## Що показати преподу

- Скріншот SELECT з WHERE та ORDER BY + результат
- Скріншот INSERT: ДО (таблиця без нового запису) → ПІСЛЯ (з новим записом)
- Скріншот UPDATE: ДО (views=5) → ПІСЛЯ (views=6)
- Скріншот DELETE: ДО → ПІСЛЯ (запис зник)
- Пояснити чому WHERE критичний для UPDATE/DELETE

---

# Lab 4: OLAP — JOIN, агрегації, GROUP BY

## Коротко

OLAP (Online Analytical Processing) — аналітичні запити. Використовуємо JOIN для зв'язків між таблицями, агрегації (COUNT, SUM, AVG) для підрахунку, GROUP BY для групування, HAVING для фільтрації груп.

## Термінологія

- **OLAP (Online Analytical Processing)** — аналітична обробка. Запити які аналізують дані, а не змінюють. EXAMPLE: "скільки лайків у кожного відео?" — це OLAP.

- **INNER JOIN** — тільки записи які мають пару в обох таблицях. EXAMPLE:
```sql
SELECT u.username, v.title
FROM "user" u INNER JOIN video v ON u.user_id = v.user_id;
```
Покаже тільки користувачів які мають відео.

- **LEFT JOIN** — всі записи з лівої таблиці + пари з правої (або NULL якщо пари немає). EXAMPLE:
```sql
SELECT u.username, v.title
FROM "user" u LEFT JOIN video v ON u.user_id = v.user_id;
```
Покаже ВСІХ користувачів, навіть тих у кого немає відео (title буде NULL).

- **FULL OUTER JOIN** — всі записи з обох таблиць. EXAMPLE:
```sql
SELECT u.username, v.title
FROM "user" u FULL OUTER JOIN video v ON u.user_id = v.user_id;
```
Всі користувачі + всі відео, навіть без пари.

- **CROSS JOIN** — декартів добуток (кожен з кожним). EXAMPLE:
```sql
SELECT u.username, v.title
FROM "user" u CROSS JOIN video v;
```
Якщо 10 юзерів і 20 відео → 200 рядків.

- **COUNT()** — кількість записів. EXAMPLE: `COUNT(video_id)` — скільки відео.

- **SUM()** — сума значень. EXAMPLE: `SUM(views)` — загальна кількість переглядів.

- **AVG()** — середнє значення. EXAMPLE: `AVG(views)` — середня кількість переглядів.

- **MIN() / MAX()** — мінімальне / максимальне значення. EXAMPLE: `MAX(views)` — відео з найбільшою кількістю переглядів.

- **GROUP BY** — групування записів для агрегації. EXAMPLE:
```sql
SELECT user_id, COUNT(*) as video_count, SUM(views) as total_views
FROM video GROUP BY user_id;
```
Для кожного користувача — кількість відео та сумарні перегляди.

- **HAVING** — фільтр для груп (як WHERE, але після GROUP BY). EXAMPLE:
```sql
SELECT user_id, COUNT(*) as cnt
FROM video GROUP BY user_id HAVING COUNT(*) > 5;
```
Тільки користувачі з більше ніж 5 відео.

- **Підзапит (Subquery)** — запит всередині запиту. EXAMPLE:
```sql
SELECT * FROM video
WHERE views > (SELECT AVG(views) FROM video);
```
Відео з переглядами вище середнього.

- **Корельований підзапит (Correlated Subquery)** — підзапит який посилається на зовнішній запит. Виконується для кожного рядка.

## Приклади з VideoHub

```sql
-- Кількість лайків на кожне відео
SELECT v.title, COUNT(l.like_id) as likes_count
FROM video v LEFT JOIN like l ON v.video_id = l.video_id AND l.is_like = TRUE
GROUP BY v.video_id, v.title
ORDER BY likes_count DESC;

-- Канали з середньою кількістю переглядів вище середнього
SELECT u.username, AVG(v.views) as avg_views
FROM "user" u JOIN video v ON u.user_id = v.user_id
GROUP BY u.user_id, u.username
HAVING AVG(v.views) > (SELECT AVG(views) FROM video);
```

## Що показати преподу

- Скріншот INNER JOIN: відео + імена авторів
- Скріншот LEFT JOIN: всі юзери (навіть без відео)
- Скріншот GROUP BY + COUNT: кількість відео на канал
- Скріншот HAVING: канали з >5 відео
- Скріншот підзапит: відео вище середнього по переглядах

---

# Lab 5: Нормалізація

## Коротко

Нормалізація — це процес організації даних для усунення дублювання та аномалій. Маємо 3 нормальні форми: 1NF (атомарні значення), 2NF (немає часткових залежностей), 3NF (немає транзитивних залежностей). Якщо дані не нормалізовані — виникають аномалії вставки, оновлення та видалення.

## Термінологія

- **Нормалізація** — процес приведення БД до нормальної форми. Мета: усунути дублювання даних та аномалії.

- **1NF (Перша нормальна форма)** — всі значення атомарні (неподільні). У кожному стовпці — одне значення. EXAMPLE порушення: `tags TEXT` містить "sql, database, tutorial" — це список в одному полі. Виправлення: створити окрему таблицю `video_tag(video_id, tag_name)`.

- **2NF (Друга нормальна форма)** — 1NF + немає часткових залежностей. Кожен не-ключовий атрибут залежить від ВСКЛОГО складеного ключа, а не від його частини. EXAMPLE: якщо PK складений (subscriber_id, channel_id), то жоден атрибут не може залежати тільки від subscriber_id.

- **3NF (Третя нормальна форма)** — 2NF + немає транзитивних залежностей. Не-ключовий атрибут не залежить від іншого не-ключового атрибуту. EXAMPLE порушення: `video_status_name TEXT` в таблиці Video — статус залежить не від PK, а від проміжного поля. Виправлення: lookup-таблиця `video_status(status_id PK, name)`.

- **Функціональна залежність** — атрибут B визначається атрибутом A. Запис: A → B. EXAMPLE: `user_id → username` — знаючи ID користувача, знаю його нікнейм.

- **Часткова залежність** — не-ключовий атрибут залежить тільки від ЧАСТИНИ складеного ключа. Порушення 2NF.

- **Транзитивна залежність** — A → B → C. C залежить від A через B. Порушення 3NF. EXAMPLE: video_id → is_public → status_name. Статус залежить від відео через булеве поле is_public.

- **Аномалія вставки** — не можемо додати дані без контексту. EXAMPLE: не можемо зберегти статус "trending" якщо ще немає відео з таким статусом.

- **Аномалія оновлення** — зміна в одному місці вимагає змін в інших. EXAMPLE: якщо status_name зберігається в багатьох рядках Video — треба змінити всюди.

- **Аномалія видалення** — видаляючи одне, втрачаємо інше. EXAMPLE: видалили останнє відео зі статусом "archived" — і статус зник взагалі.

- **ALTER TABLE** — команда зміни структури таблиці. EXAMPLE:
```sql
-- Додаємо lookup-таблицю для статусів
CREATE TABLE video_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO video_status (name) VALUES ('public'), ('private'), ('unlisted');

ALTER TABLE video ADD COLUMN status_id INTEGER REFERENCES video_status(status_id);
```

- **Lookup-таблиця (довідник)** — таблиця з допустимими значеннями. EXAMPLE: `video_status` містить "public", "private", "unlisted" — замість того щоб зберігати текст в кожному відео.

## Приклад: від денормалізованого до нормалізованого

**Було (порушення 1NF):**
```sql
-- tags в одному полі — не атомарно!
video(video_id, title, tags)
-- tags = "sql,database,tutorial"
```

**Стало (1NF):**
```sql
video(video_id, title)
video_tag(video_id, tag_name)  -- кожен тег — окремий рядок
```

## Що показати преподу

- Приклад денормалізованої таблиці (з порушеннями)
- Скріншот ALTER TABLE: до і після нормалізації
- Створення lookup-таблиці video_status
- Пояснити 3 типи аномалій на прикладах з VideoHub
- Показати як video_tag усуває порушення 1NF

---

# Lab 6: Prisma ORM та міграції

## Коротко

Prisma — це ORM (Object-Relational Mapping) для Node.js. Замість написання SQL вручну, описуємо схему в файлі `schema.prisma`, а Prisma генерує SQL та міграції автоматично. Додали модель Playlist та PlaylistVideo (M:N).

## Термінологія

- **ORM (Object-Relational Mapping)** — технологія яка зв'язує об'єкти коду з таблицями БД. Замість SQL-запитів пишемо код на JavaScript/TypeScript. EXAMPLE: замість `SELECT * FROM video` пишемо `prisma.video.findMany()`.

- **Міграція (Migration)** — SQL-скрипт для зміни структури БД. Prisma генерує міграції автоматично при зміні schema.prisma. EXAMPLE: додали нову модель → Prisma створив SQL-файл з CREATE TABLE.

- **schema.prisma** — файл опису схеми БД мовою Prisma. Містить моделі, зв'язки, конфігурацію БД.

- **model** — опис таблиці в schema.prisma. EXAMPLE:
```prisma
model User {
  user_id    BigInt   @id @default(autoincrement())
  username   String   @db.VarChar(30) @unique
  email      String   @db.VarChar(255) @unique
  video      Video[]
}
```

- **@relation** — анотація зв'язку між моделями. EXAMPLE:
```prisma
model Video {
  video_id BigInt  @id @default(autoincrement())
  user_id  BigInt
  user     User    @relation(fields: [user_id], references: [user_id])
}
```

- **prisma db pull** — команда яка читає існуючу БД та генерує schema.prisma. EXAMPLE: якщо БД вже створена через SQL — `npx prisma db pull` імпортує всі таблиці в Prisma-схему.

- **prisma migrate dev** — команда яка створює та застосовує міграцію. EXAMPLE:
```bash
npx prisma migrate dev --name "add_playlist"
```
Prisma порівняє стару і нову схему, згенерує SQL та виконає його.

- **Prisma Studio** — веб-інтерфейс для перегляду та редагування даних БД. EXAMPLE: `npx prisma studio` — відкриває UI де бачиш всі таблиці, можеш додавати/змінювати записи.

- **DATABASE_URL** — змінна оточення з адресою підключення до БД. EXAMPLE:
```
DATABASE_URL="postgresql://user:password@localhost:5432/videohub"
```

## Таблиця команд Prisma

| Команда | Що робить |
|---------|-----------|
| `npx prisma init` | Ініціалізація Prisma в проєкті |
| `npx prisma db pull` | Імпорт існуючої БД в schema.prisma |
| `npx prisma migrate dev --name "..."` | Створення та застосування міграції |
| `npx prisma migrate deploy` | Застосування міграцій на продакшн |
| `npx prisma studio` | Запуск веб-інтерфейсу |
| `npx prisma generate` | Генерація Prisma Client |

## Приклад: додаємо Playlist

```prisma
// Додали в schema.prisma:
model Playlist {
  playlist_id BigInt   @id @default(autoincrement())
  user_id     BigInt
  title       String   @db.VarChar(255)
  created_at  DateTime @default(now())
  user        User     @relation(fields: [user_id], references: [user_id])
  videos      PlaylistVideo[]
}

model PlaylistVideo {
  playlist_id BigInt
  video_id    BigInt
  added_at    DateTime @default(now())
  playlist    Playlist @relation(fields: [playlist_id], references: [playlist_id])
  video       Video    @relation(fields: [video_id], references: [video_id])
  @@id([playlist_id, video_id])
}
```

Після зміни: `npx prisma migrate dev --name "add_playlist"` → Prisma згенерує SQL та виконає CREATE TABLE.

## Що показати преподу

- Скріншот schema.prisma (всі моделі)
- Скріншот терміналу з `prisma migrate dev` (без помилок)
- Скріншот Prisma Studio з таблицею Playlist
- Згенерований SQL файл міграції
- Пояснити що таке ORM і чому це зручно

---

# Extras: Window Functions, CTE, Recursive CTE

## Коротко

Це додаткові можливості SQL для складних аналітичних запитів. Window Functions — агрегації без GROUP BY. CTE (Common Table Expression) — тимчасові іменовані набори даних. Recursive CTE — рекурсивні запити (дерева, ієрархії).

## Термінологія

- **Window Function** — функція яка виконує агрегацію по "вікну" (набору рядків), не згортаючи результат. Кожний рядок зберігається.

- **ROW_NUMBER()** — номер рядка в вікні. EXAMPLE:
```sql
SELECT video_id, title, views,
       ROW_NUMBER() OVER (ORDER BY views DESC) as rank
FROM video;
```
Нумерує відео від найбільш переглядуваного.

- **RANK()** — рейтинг з пропусками при однакових значеннях. EXAMPLE: якщо два відео мають по 1000 переглядів — обидва отримають rank=2, наступне rank=4.

- **OVER()** — визначає вікно для window function.

- **PARTITION BY** — розділяє дані на групи (як GROUP BY, але без згортання). EXAMPLE:
```sql
SELECT u.username, v.title, v.views,
       ROW_NUMBER() OVER (PARTITION BY v.user_id ORDER BY v.views DESC) as video_rank
FROM video v JOIN "user" u ON v.user_id = u.user_id;
```
Нумерує відео ВСЕРЕДИНІ кожного каналу (по переглядах).

## CTE (Common Table Expression)

- **CTE** — тимчасовий іменований набір даних. Використовуємо `WITH`. EXAMPLE:
```sql
WITH user_stats AS (
    SELECT user_id, COUNT(*) as total_videos, SUM(views) as total_views
    FROM video GROUP BY user_id
)
SELECT u.username, s.total_videos, s.total_views
FROM "user" u JOIN user_stats s ON u.user_id = s.user_id
WHERE s.total_views > 10000;
```
CTE `user_stats` — тимчасова таблиця з статистикою кожного юзера. Потім використовуємо її в основному запиті.

## Recursive CTE

- **Recursive CTE** — рекурсивний запит який посилається сам на себе. Використовуємо для дерев та ієрархій. EXAMPLE: дерево коментарів (кореневий коментар → відповіді → відповіді на відповіді).

```sql
WITH RECURSIVE comment_tree AS (
    -- База: кореневі коментарі
    SELECT comment_id, user_id, text, parent_comment_id, 1 as depth
    FROM comment
    WHERE parent_comment_id IS NULL AND video_id = 5

    UNION ALL

    -- Рекурсія: відповіді
    SELECT c.comment_id, c.user_id, c.text, c.parent_comment_id, ct.depth + 1
    FROM comment c
    JOIN comment_tree ct ON c.parent_comment_id = ct.comment_id
)
SELECT * FROM comment_tree ORDER BY depth;
```

Цей запит покаже ВСІ коментарі до відео #5 у вигляді дерева: спочатку кореневі (depth=1), потім відповіді на них (depth=2), потім відповіді на відповіді (depth=3) і так далі.

## Інші корисні Window Functions

| Функція | Що робить |
|---------|-----------|
| `ROW_NUMBER()` | Номер рядка (1, 2, 3...) |
| `RANK()` | Рейтинг з пропусками (1, 2, 2, 4) |
| `DENSE_RANK()` | Рейтинг без пропусків (1, 2, 2, 3) |
| `LAG()` | Значення з попереднього рядка |
| `LEAD()` | Значення з наступного рядка |
| `SUM() OVER()` | Кумулятивна сума |

## Приклад: топ-3 відео кожного каналу

```sql
WITH ranked AS (
    SELECT video_id, user_id, title, views,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY views DESC) as rn
    FROM video
)
SELECT * FROM ranked WHERE rn <= 3;
```

## Що показати преподу

- Скріншот ROW_NUMBER() з сортуванням по переглядах
- Скріншот PARTITION BY — нумерація відео всередині кожного каналу
- Скріншот CTE з user_stats
- Скріншот Recursive CTE — дерево коментарів з depth
- Пояснити різницю між GROUP BY (згортає) та Window Function (не згортає)
