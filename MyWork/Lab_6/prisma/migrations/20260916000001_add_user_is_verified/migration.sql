-- Migration: add_user_is_verified
-- Додаємо стовпець is_verified до таблиці "User"
-- Призначає true/false: чи верифіковано акаунт (галочка поруч з нікнеймом)
-- DEFAULT false — усі існуючі користувачі автоматично отримують значення false

ALTER TABLE "User" ADD COLUMN "is_verified" BOOLEAN NOT NULL DEFAULT false;
