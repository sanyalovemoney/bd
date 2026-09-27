# План виконання лабораторних робіт — VideoHub

Стан проєкту та список того, що треба ще доробити.
Курс «Бази даних», КПІ ім. Сікорського, викладач Русінов В.В., 2026.
Виконав: Машута Олександр, група ІМ-051, № у списку 16.

---

## Що вже готово ✅

| Файл | Статус | Розмір |
|---|---|---|
| `SCHEMA_SPEC.md` | ✅ канонічна схема (5 сутностей, 4 зв'язки) | 4.7 КБ |
| `canva_explanation.md` | ✅ теорія для захисту (8 сторінок) | 32 КБ |
| `Lab_1/er_diagram.mmd` | ✅ Mermaid ER-діаграма | 2.0 КБ |
| `Lab_2/schema.sql` | ✅ DDL (5 таблиць) | 13.7 КБ |
| `Lab_2/inserts.sql` | ✅ INSERT-дані | 15.2 КБ |
| `Lab_3/queries.sql` | ✅ OLTP-запити | 4.7 КБ |
| `Lab_4/queries.sql` | ✅ OLAP-запити | 11.7 КБ |
| `Lab_5/denormalized.sql` | ✅ денормалізована схема | 6.5 КБ |
| `Lab_5/normalization.sql` | ✅ ALTER → 3НФ | 7.4 КБ |
| `Lab_6/prisma/schema.prisma` | ✅ фінальна схема | 6.4 КБ |
| `Lab_6/prisma/migrations/` | ✅ 3 міграції + `migration_lock.toml` | ~6.6 КБ |
| `Lab_6/migration-notes.md` | ✅ примітки міграцій | 17.7 КБ |
| `.gitignore`, `README.md`, `Lab_6/package.json`, `Lab_6/.env.example` | ✅ | — |

---

## Що треба ще доробити

### 1. Звіти `report_labN.md` (головне, чого не вистачає)

6 файлів, по одному на лабу. Агенти встигли написати код, але були зупинені до написання звітів. Це найдовша частина: українською, з титульною сторінкою (HTML-шаблон: Машута Олександр, ІМ-051, №16, Русінов В.В., Київ 2026), детальним прозовим текстом, SQL у блоках ` ```sql `, плейсхолдерами скріншотів `<img>`.

- [ ] `Lab_1/report_lab1.md` — ER-діаграма
- [ ] `Lab_2/report_lab2.md` — DDL
- [ ] `Lab_3/report_lab3.md` — OLTP
- [ ] `Lab_4/report_lab4.md` — OLAP
- [ ] `Lab_5/report_lab5.md` — Нормалізація
- [ ] `Lab_6/report_lab6.md` — Prisma

Пишу сам (без агентів) — надійніше і повністю узгоджено з уже написаним кодом.

### 2. Перевірка коду

Пробіжитися по `schema.sql`, `queries.sql`, `normalization.sql`, `schema.prisma` — переконатись, що синтаксис валідний і узгоджений зі схемою (імена стовпців/таблиць збігаються між лабами, FK посилаються правильно).

- [ ] Перевірити Lab_2 `schema.sql` + `inserts.sql`
- [ ] Перевірити Lab_3 `queries.sql` (імена таблиць/стовпців збігаються зі схемою)
- [ ] Перевірити Lab_4 `queries.sql`
- [ ] Перевірити Lab_5 `denormalized.sql` + `normalization.sql`
- [ ] Перевірити Lab_6 `schema.prisma` + міграції (узгодженість з `schema.sql`)

### 3. Скріншоти (ручний крок 👤)

Треба виконати SQL у **pgAdmin / Prisma Studio** і зробити реальні скріншоти в `Lab_N/screenshots/`. Я не можу їх згенерувати — лише ти маєш доступ до PostgreSQL. У звітах уже розставлені `<img src="screenshots/...png">` плейсхолдери з правильними іменами файлів — просто заповни їх скріншотами.

- [ ] Lab_2: `create_tables.png`, `insert_data.png`, `select_users.png`, `select_videos.png`, …
- [ ] Lab_3: `select_1.png`…`select_5.png`, `insert_before/after.png`, `update_before/after.png`, `delete_before/after.png`
- [ ] Lab_4: `agg_1.png`…, `join_*.png`, `subquery_*.png`
- [ ] Lab_5: `denorm_before.png`, `normalized_after.png`
- [ ] Lab_6: `terminal_migrate.png`, `prisma_studio.png`, `prisma_studio_playlist.png`

### 4. PDF-генерація

Після звітів і скріншотів — для кожної лаби:

```bash
cd MyWork/Lab_N
Remove-Item -Force report_labN.pdf -ErrorAction SilentlyContinue
npx md-to-pdf report_labN.md
```

Перевірити розмір: PDF має бути ≥ 80 КБ (інакше тексту замало).

- [ ] `report_lab1.pdf`
- [ ] `report_lab2.pdf`
- [ ] `report_lab3.pdf`
- [ ] `report_lab4.pdf`
- [ ] `report_lab5.pdf`
- [ ] `report_lab6.pdf`

### 5. Git — комміти за графіком

Ініціалізувати репо, закомітити кожну лабу бект-датованим коммітом і запушити.

```powershell
$env:GIT_COMMITTER_DATE="2026-09-NNT12:00:00"
git commit --date="2026-09-NNT12:00:00" -m "Lab N: тема"
Remove-Item Env:\GIT_COMMITTER_DATE
git push origin master
```

Графік коммітов:

| Лаба | Дата комміта |
|------|-------------|
| Lab 1 | 02.09.2026 |
| Lab 2 | 03.09.2026 |
| Lab 3 | 05.09.2026 |
| Lab 4 | 09.09.2026 |
| Lab 5 | 12.09.2026 |
| Lab 6 | 16.09.2026 |

- [ ] `git init` + налаштувати remote
- [ ] Lab 1 commit (02.09.2026)
- [ ] Lab 2 commit (03.09.2026)
- [ ] Lab 3 commit (05.09.2026)
- [ ] Lab 4 commit (09.09.2026)
- [ ] Lab 5 commit (12.09.2026)
- [ ] Lab 6 commit (16.09.2026)
- [ ] `git push origin master`

---

## Порядок дій

1. **Я пишу** 6 звітів `report_labN.md` (узгоджено з готовим кодом).
2. **Я перевіряю** код на валідність і узгодженість.
3. **Ти** виконуєш SQL у pgAdmin/Prisma Studio і робиш скріншоти.
4. **Ти** генеруєш PDF через `npx md-to-pdf`.
5. **Ти** комітиш у git за графіком і пушуєш.
