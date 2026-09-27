# VideoHub — лабораторні роботи з баз даних

Відеохостинг-платформа (аналог YouTube). Проєкт курсу «Бази даних», КПІ ім. Сікорського, викладач Русінов В.В., 2026.

Виконав: Машута Олександр, група ІМ-051, № у списку 16.

## Структура

```
MyWork/
├── Lab_1/   ER-діаграма          (02.09.2026)
├── Lab_2/   DDL — PostgreSQL     (03.09.2026)
├── Lab_3/   OLTP — DML          (05.09.2026)
├── Lab_4/   OLAP — аналітика    (09.09.2026)
├── Lab_5/   Нормалізація 3НФ    (12.09.2026)
├── Lab_6/   Prisma ORM міграції (16.09.2026)
├── canva_explanation.md   теорія для захисту
└── SCHEMA_SPEC.md         канонічна схема (спільна для всіх лаб)
```

## Сутності

`User`, `Video`, `Comment`, `Like`, `Subscription` — 5 сутностей, 4 зв'язки:

| Зв'язок | Тип | Реалізація |
|---|---|---|
| User → Video | 1:N | FK `video.user_id` ON DELETE CASCADE |
| User → Comment ← Video | 1:N + 1:N | два FK у Comment |
| User → Like ← Video | 1:N + 1:N | FK + UNIQUE(user_id, video_id) |
| User → Subscription ← User | M:N | асоціативна таблиця, складений PK |

## Запуск

```bash
# Lab 2 — створення схеми (psql або pgAdmin)
psql -d videohub -f MyWork/Lab_2/schema.sql
psql -d videohub -f MyWork/Lab_2/inserts.sql

# Lab 6 — Prisma
cd MyWork/Lab_6
cp .env.example .env   # відредагувати DATABASE_URL
npm install
npx prisma migrate dev
npx prisma studio
```

## Звіти

Кожна лаба має `report_labN.md` → генерується PDF: `npx md-to-pdf report_labN.md`.
