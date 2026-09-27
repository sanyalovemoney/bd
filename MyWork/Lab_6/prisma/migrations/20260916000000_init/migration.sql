-- Migration: init
-- Initial introspected schema from existing VideoHub PostgreSQL database (Lab 2/5)
-- 5 base tables: "User", "Video", "Comment", "Like", "Subscription"

-- Create "User" table (користувач / канал)
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

-- Create unique indexes on User
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "User_google_id_key" ON "User"("google_id");

-- Create "Video" table (відео на платформі)
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

-- Create index on Video.user_id for FK performance
CREATE INDEX "Video_user_id_idx" ON "Video"("user_id");

-- Create "Comment" table (коментар до відео)
CREATE TABLE "Comment" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "video_id" INTEGER NOT NULL,
    "parent_comment_id" INTEGER,
    "text" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Comment_pkey" PRIMARY KEY ("id")
);

-- Create indexes on Comment for FK lookups
CREATE INDEX "Comment_user_id_idx" ON "Comment"("user_id");
CREATE INDEX "Comment_video_id_idx" ON "Comment"("video_id");
CREATE INDEX "Comment_parent_comment_id_idx" ON "Comment"("parent_comment_id");

-- Create "Like" table (вподобайка / дизлайк)
CREATE TABLE "Like" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "video_id" INTEGER NOT NULL,
    "is_like" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Like_pkey" PRIMARY KEY ("id")
);

-- Create unique index: один юзер — один лайк/дизлайк на відео
CREATE UNIQUE INDEX "Like_user_id_video_id_key" ON "Like"("user_id", "video_id");
CREATE INDEX "Like_video_id_idx" ON "Like"("video_id");

-- Create "Subscription" table (M:N self-relation на User)
CREATE TABLE "Subscription" (
    "subscriber_id" INTEGER NOT NULL,
    "channel_id" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Subscription_pkey" PRIMARY KEY ("subscriber_id", "channel_id")
);

-- Create index on Subscription.channel_id for FK lookups
CREATE INDEX "Subscription_channel_id_idx" ON "Subscription"("channel_id");

-- AddForeignKey: Video → User ON DELETE CASCADE
ALTER TABLE "Video" ADD CONSTRAINT "Video_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey: Comment → User, Comment → Video, Comment → Comment (self)
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_video_id_fkey"
    FOREIGN KEY ("video_id") REFERENCES "Video"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_parent_comment_id_fkey"
    FOREIGN KEY ("parent_comment_id") REFERENCES "Comment"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey: Like → User, Like → Video
ALTER TABLE "Like" ADD CONSTRAINT "Like_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Like" ADD CONSTRAINT "Like_video_id_fkey"
    FOREIGN KEY ("video_id") REFERENCES "Video"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey: Subscription → User (subscriber), Subscription → User (channel)
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_subscriber_id_fkey"
    FOREIGN KEY ("subscriber_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_channel_id_fkey"
    FOREIGN KEY ("channel_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
