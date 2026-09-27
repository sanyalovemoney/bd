# Migration Notes — Lab 6 (Prisma ORM, VideoHub)

Цей документ фіксує кожну міграцію, застосовану до схеми PostgreSQL проєкту **VideoHub** за допомогою Prisma ORM. Кожна міграція — це окрема зміна схеми, згенерована командою `npx prisma migrate dev --name ...` і збережена у `prisma/migrations/<timestamp>_<name>/migration.sql`. Міграції застосовуються послідовно і відтворюються — це гарантує, що будь-який розробник у команді може підняти базу даних з нуля до актуального стану.

Усього було застосовано **3 міграції**:

1. `init` — початкова інтроспекція 5 базових таблиць (`User`, `Video`, `Comment`, `Like`, `Subscription`)
2. `add_user_is_verified` — додавання стовпця `is_verified` до таблиці `User`
3. `add_playlist` — додавання таблиць `Playlist` та `PlaylistVideo` (M:N)

---

## 1. Міграція `init` — початкова інтроспекція

### Що змінилося

Команда `npx prisma db pull` аналізує існуючу базу даних PostgreSQL (створену в Lab 2/5 за допомогою чистого SQL) і генерує файл `prisma/schema.prisma` з моделями, що відповідають усім 5 таблицям VideoHub. Перша міграція `init` — це формальна фіксація цієї інтроспекції у системі міграцій Prisma. Вона не змінює базу, а лише **задокументовує** поточний стан у `migration.sql`.

### Команда терміналу

```bash
npx prisma db pull
npx prisma migrate dev --name init
```

Перша команда генерує `schema.prisma` з існуючої БД, друга — створює `migrations/20260916000000_init/migration.sql` і помічає цю міграцію як застосовану в `_prisma_migrations`.

### Prisma модель (після `db pull`) — фрагмент

```prisma
model User {
  id            Int       @id @default(autoincrement())
  username      String    @unique @db.VarChar(30)
  email         String    @unique @db.VarChar(255)
  password_hash String?   @db.VarChar(255)
  google_id     String?   @unique @db.VarChar(255)
  avatar_url    String?
  bio           String?
  is_channel    Boolean   @default(false)
  created_at    DateTime  @default(now()) @db.Timestamptz

  videos    Video[]
  comments  Comment[]
  likes     Like[]
  subscriptions Subscription[] @relation("subscriber")
  channels      Subscription[] @relation("channel")
}

model Video {
  id               Int       @id @default(autoincrement())
  user_id          Int
  title            String    @db.VarChar(255)
  description      String?
  video_url        String
  thumbnail_url    String?
  duration_seconds Int
  views            Int       @default(0)
  is_public        Boolean   @default(true)
  created_at       DateTime  @default(now()) @db.Timestamptz

  user     User      @relation(fields: [user_id], references: [id], onDelete: Cascade)
  comments Comment[]
  likes    Like[]
}
```

### Згенерований SQL (`migrations/20260916000000_init/migration.sql`)

```sql
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "username" VARCHAR(30) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255),
    "google_id" VARCHAR(255),
    "avatar_url" TEXT,
    "bio" TEXT,
    "is_channel" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "User_username_key" ON "User"("username");
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "User_google_id_key" ON "User"("google_id");

CREATE TABLE "Video" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "video_url" TEXT NOT NULL,
    "thumbnail_url" TEXT,
    "duration_seconds" INTEGER NOT NULL,
    "views" INTEGER NOT NULL DEFAULT 0,
    "is_public" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Video_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Comment" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "video_id" INTEGER NOT NULL,
    "parent_comment_id" INTEGER,
    "text" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Comment_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Like" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "video_id" INTEGER NOT NULL,
    "is_like" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Like_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Like_user_id_video_id_key" ON "Like"("user_id", "video_id");

CREATE TABLE "Subscription" (
    "subscriber_id" INTEGER NOT NULL,
    "channel_id" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Subscription_pkey" PRIMARY KEY ("subscriber_id", "channel_id")
);

ALTER TABLE "Video" ADD CONSTRAINT "Video_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
-- ... інші FK для Comment, Like, Subscription
```

Уся база даних залишилась незмінною — Prisma просто зафіксувала її стан у `migration.sql`.

---

## 2. Міграція `add_user_is_verified` — новий стовпець у User

### Що змінилося

До моделі `User` додано булеве поле `is_verified` з дефолтним значенням `false`. Це поле позначає, чи пройшов користувач верифікацію (аналог «галочки» поруч з нікнеймом на YouTube). Оскільки це NOT NULL стовпець із DEFAULT, Prisma генерує `ALTER TABLE ADD COLUMN` без блокування — усі існуючі рядки автоматично отримують `false`.

### Команда терміналу

```bash
npx prisma migrate dev --name add_user_is_verified
```

### Prisma модель — **ДО**

```prisma
model User {
  id            Int       @id @default(autoincrement())
  username      String    @unique @db.VarChar(30)
  email         String    @unique @db.VarChar(255)
  password_hash String?   @db.VarChar(255)
  google_id     String?   @unique @db.VarChar(255)
  avatar_url    String?
  bio           String?
  is_channel    Boolean   @default(false)
  created_at    DateTime  @default(now()) @db.Timestamptz
  // ❌ is_verified ще немає
}
```

### Prisma модель — **ПІСЛЯ**

```prisma
model User {
  id            Int       @id @default(autoincrement())
  username      String    @unique @db.VarChar(30)
  email         String    @unique @db.VarChar(255)
  password_hash String?   @db.VarChar(255)
  google_id     String?   @unique @db.VarChar(255)
  avatar_url    String?
  bio           String?
  is_channel    Boolean   @default(false)
  is_verified   Boolean   @default(false) // ✅ нове поле
  created_at    DateTime  @default(now()) @db.Timestamptz
}
```

### Згенерований SQL (`migrations/20260916000001_add_user_is_verified/migration.sql`)

```sql
ALTER TABLE "User" ADD COLUMN "is_verified" BOOLEAN NOT NULL DEFAULT false;
```

Це єдиний рядок SQL — Prisma зрозумів, що в схемі з'явилося нове NOT NULL поле з DEFAULT, і згенерував відповідний `ALTER TABLE`. Зверніть увагу на `NOT NULL DEFAULT false`: Prisma гарантує, що існуючі рядки (які вже були в таблиці з Lab 2/5) автоматично заповняться `false`, тому міграція не завершиться помилкою.

---

## 3. Міграція `add_playlist` — нові таблиці Playlist і PlaylistVideo

### Що змінилося

Додано дві нові моделі:

- **Playlist** — плейлист, створений користувачем. Має FK на `User` (автор плейлиста) та 1:N зв'язок із `PlaylistVideo`.
- **PlaylistVideo** — junction-таблиця для M:N між `Playlist` та `Video`. Має складений PK (`playlist_id`, `video_id`) і обидва FK з `ON DELETE CASCADE` (якщо видалити плейлист або відео — запис у junction автоматично зникає).

Це типова реалізація M:N зв'язку в реляційній БД: Prisma вимагає явної junction-таблиці, на відміну від, наприклад, Django.

### Команда терміналу

```bash
npx prisma migrate dev --name add_playlist
```

### Prisma модель — **ДО** (немає Playlist/PlaylistVideo)

```prisma
// У схемі лише 5 базових моделей + is_verified
model User {
  // ...
  playlists Playlist[]  // ❌ ще немає
}
model Video {
  // ...
  playlists PlaylistVideo[]  // ❌ ще немає
}
```

### Prisma модель — **ПІСЛЯ**

```prisma
model Playlist {
  id         Int      @id @default(autoincrement())
  user_id    Int
  title      String   @db.VarChar(255)
  created_at DateTime @default(now()) @db.Timestamptz

  user   User            @relation(fields: [user_id], references: [id], onDelete: Cascade)
  videos PlaylistVideo[]

  @@index([user_id])
}

model PlaylistVideo {
  playlist_id Int
  video_id    Int
  added_at    DateTime @default(now()) @db.Timestamptz

  playlist Playlist @relation(fields: [playlist_id], references: [id], onDelete: Cascade)
  video    Video    @relation(fields: [video_id],    references: [id], onDelete: Cascade)

  @@id([playlist_id, video_id])
  @@index([video_id])
}
```

### Згенерований SQL (`migrations/20260916000002_add_playlist/migration.sql`)

```sql
CREATE TABLE "Playlist" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Playlist_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "Playlist_user_id_idx" ON "Playlist"("user_id");

CREATE TABLE "PlaylistVideo" (
    "playlist_id" INTEGER NOT NULL,
    "video_id" INTEGER NOT NULL,
    "added_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "PlaylistVideo_pkey" PRIMARY KEY ("playlist_id", "video_id")
);

CREATE INDEX "PlaylistVideo_video_id_idx" ON "PlaylistVideo"("video_id");

ALTER TABLE "Playlist" ADD CONSTRAINT "Playlist_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "PlaylistVideo" ADD CONSTRAINT "PlaylistVideo_playlist_id_fkey"
    FOREIGN KEY ("playlist_id") REFERENCES "Playlist"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "PlaylistVideo" ADD CONSTRAINT "PlaylistVideo_video_id_fkey"
    FOREIGN KEY ("video_id") REFERENCES "Video"("id") ON DELETE CASCADE ON UPDATE CASCADE;
```

Prisma згенерувала `CREATE TABLE` для обох нових таблиць, індекси для швидких FK-lookup, і три `ALTER TABLE ADD CONSTRAINT` для всіх foreign keys. Зверніть увагу на `ON DELETE CASCADE` — якщо видалити `User`, видалиться і його `Playlist`; якщо видалити `Video`, видалиться запис із `PlaylistVideo`.

---

## Перевірка через Prisma Client

Щоб переконатися, що нова схема працює, створимо тестовий плейлист, додамо до нього відео і зробимо запит із `include`. Цей скрипт можна запустити після `npx prisma generate` (генерація TypeScript-клієнта зі `schema.prisma`):

```bash
npx prisma generate
node scripts/test_playlist.js
```

### Приклад скрипта (`scripts/test_playlist.js`)

```javascript
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  // 1. Створюємо плейлист для користувача з id = 1
  const playlist = await prisma.playlist.create({
    data: {
      user_id: 1,
      title: 'Мій перший плейлист',
    },
  });
  console.log('✅ Створено плейлист:', playlist);

  // 2. Додаємо відео з id = 1 і id = 2 до цього плейлиста
  await prisma.playlistVideo.createMany({
    data: [
      { playlist_id: playlist.id, video_id: 1 },
      { playlist_id: playlist.id, video_id: 2 },
    ],
  });
  console.log('✅ Додано 2 відео до плейлиста');

  // 3. Знайти плейlist з include — бачимо owner (User) і videos (PlaylistVideo[])
  const result = await prisma.playlist.findMany({
    where: { id: playlist.id },
    include: {
      user: true,   // → User object
      videos: {
        include: {
          video: true,  // → Video object через junction
        },
      },
    },
  });
  console.log(JSON.stringify(result, null, 2));
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

### Очікуваний результат

```json
[
  {
    "id": 1,
    "user_id": 1,
    "title": "Мій перший плейлист",
    "created_at": "2026-09-16T12:00:00.000Z",
    "user": {
      "id": 1,
      "username": "john_doe",
      "email": "john@example.com",
      "is_channel": true,
      "is_verified": false
    },
    "videos": [
      {
        "playlist_id": 1,
        "video_id": 1,
        "added_at": "2026-09-16T12:01:00.000Z",
        "video": { "id": 1, "title": "Prisma ORM Tutorial", "views": 42 }
      },
      {
        "playlist_id": 1,
        "video_id": 2,
        "added_at": "2026-09-16T12:01:00.000Z",
        "video": { "id": 2, "title": "PostgreSQL for Beginners", "views": 150 }
      }
    ]
  }
]
```

Зверніть увагу на `include: { videos: { include: { video: true } } }` — Prisma автоматично проходить через junction-таблицю `PlaylistVideo` і підтягує дані з `Video`. Це те, за що розробники люблять ORM: не треба писати `JOIN` вручну.

---

## Prisma Studio — скріншоти

### Скріншот: Playlist у Prisma Studio

<img src="screenshots/prisma_studio_playlist.png" style="width: 100%; max-width: 800px;">

Prisma Studio показує таблицю `Playlist` із рядком, який ми щойно створили. Кожен стовпець (`id`, `user_id`, `title`, `created_at`) видно в UI. Можна редагувати дані прямо в браузері — Prisma Studio автоматично генерує відповідні `UPDATE`-запити.

### Скріншот: термінал із migrate dev

<img src="screenshots/terminal_migrate.png" style="width: 100%; max-width: 800px;">

Термінал після запуску всіх трьох `npx prisma migrate dev --name ...`. Видно повідомлення `Applying migration ...` і фінальне `✔ Generated Prisma Client`. Це підтверджує, що кожна міграція успішно застосована і Prisma Client згенеровано для нової схеми.

---

## Фінальна структура `prisma/migrations/`

```
prisma/
├── schema.prisma                       # фінальна схема (7 моделей)
├── migrations/
│   ├── migration_lock.toml             # provider = "postgresql"
│   ├── 20260916000000_init/
│   │   └── migration.sql               # 5 базових таблиць
│   ├── 20260916000001_add_user_is_verified/
│   │   └── migration.sql               # ALTER TABLE "User" ADD COLUMN "is_verified"
│   └── 20260916000002_add_playlist/
│       └── migration.sql               # CREATE TABLE "Playlist", "PlaylistVideo"
```

Кожен файл `migration.sql` — це чистий, відтворюваний SQL. Якщо інший розробник зробить `git clone`, він запускає `npx prisma migrate deploy` — і база даних піднімається до фінального стану за одну команду.

---

## Підсумок змін

| Міграція | Тип зміни | SQL-команда | Що додано |
|----------|-----------|-------------|-----------|
| `init` | Introspection | `CREATE TABLE` ×5 | User, Video, Comment, Like, Subscription |
| `add_user_is_verified` | Add column | `ALTER TABLE ADD COLUMN` | `User.is_verified BOOLEAN NOT NULL DEFAULT false` |
| `add_playlist` | Add tables | `CREATE TABLE` ×2 | Playlist (1:N з User), PlaylistVideo (M:N junction) |

Усі три міграції успішно застосовані. Фінальна схема містить 7 моделей, 4 зв'язки 1:N, 2 self-relation (Comment replies, Subscription), і 2 M:N зв'язки (Subscription — через складений PK, Playlist↔Video — через junction `PlaylistVideo`).
