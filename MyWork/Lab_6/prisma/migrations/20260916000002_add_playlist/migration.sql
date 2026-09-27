-- Migration: add_playlist
-- Додаємо моделі Playlist та PlaylistVideo (M:N між User-Playlist та Playlist-Video)

-- Create "Playlist" table — плейлист, створений користувачем
CREATE TABLE "Playlist" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Playlist_pkey" PRIMARY KEY ("id")
);

-- Create index for FK lookup
CREATE INDEX "Playlist_user_id_idx" ON "Playlist"("user_id");

-- Create "PlaylistVideo" table — junction-таблиця M:N між Playlist та Video
CREATE TABLE "PlaylistVideo" (
    "playlist_id" INTEGER NOT NULL,
    "video_id" INTEGER NOT NULL,
    "added_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PlaylistVideo_pkey" PRIMARY KEY ("playlist_id", "video_id")
);

-- Create index for FK lookup on video_id
CREATE INDEX "PlaylistVideo_video_id_idx" ON "PlaylistVideo"("video_id");

-- AddForeignKey: Playlist → User ON DELETE CASCADE
ALTER TABLE "Playlist" ADD CONSTRAINT "Playlist_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey: PlaylistVideo → Playlist, PlaylistVideo → Video (обидва CASCADE)
ALTER TABLE "PlaylistVideo" ADD CONSTRAINT "PlaylistVideo_playlist_id_fkey"
    FOREIGN KEY ("playlist_id") REFERENCES "Playlist"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "PlaylistVideo" ADD CONSTRAINT "PlaylistVideo_video_id_fkey"
    FOREIGN KEY ("video_id") REFERENCES "Video"("id") ON DELETE CASCADE ON UPDATE CASCADE;
