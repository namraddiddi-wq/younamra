-- =============================================
-- 유남라 팬사이트 Supabase 초기 SQL
-- Supabase > SQL Editor 에서 전체 실행
-- =============================================

-- 1. songs (노래책)
CREATE TABLE IF NOT EXISTS public.songs (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artist     TEXT,
  title      TEXT,
  genre      TEXT DEFAULT 'etc',
  level      INT DEFAULT 3,
  memo       TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read songs"  ON public.songs FOR SELECT USING (true);
CREATE POLICY "Auth insert songs"  ON public.songs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Auth delete songs"  ON public.songs FOR DELETE TO authenticated USING (true);
CREATE POLICY "Auth update songs"  ON public.songs FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- 2. schedules (일정)
CREATE TABLE IF NOT EXISTS public.schedules (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date        DATE NOT NULL UNIQUE,
  status      TEXT DEFAULT 'normal',
  slot1_title TEXT,
  slot2_title TEXT,
  slot1_time  TEXT DEFAULT '17:00',
  slot2_time  TEXT,
  note        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read schedules"  ON public.schedules FOR SELECT USING (true);
CREATE POLICY "Auth insert schedules"  ON public.schedules FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Auth update schedules"  ON public.schedules FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Auth delete schedules"  ON public.schedules FOR DELETE TO authenticated USING (true);

-- 3. overlay_state (OBS)
CREATE TABLE IF NOT EXISTS public.overlay_state (
  id          INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  song_title  TEXT DEFAULT '',
  song_artist TEXT DEFAULT '',
  is_visible  BOOLEAN DEFAULT FALSE,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO public.overlay_state (id, song_title, song_artist, is_visible)
VALUES (1, '', '', false) ON CONFLICT (id) DO NOTHING;
ALTER TABLE public.overlay_state ENABLE ROW LEVEL SECURITY;
CREATE POLICY "overlay_read"     ON public.overlay_state FOR SELECT USING (true);
CREATE POLICY "overlay_all_auth" ON public.overlay_state FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 4. 업보 테이블 5종
CREATE TABLE IF NOT EXISTS public.upbo_task_types (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL,
  category   TEXT DEFAULT 'normal',
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS public.upbo_members (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nickname   TEXT NOT NULL,
  user_id    TEXT,
  memo       TEXT,
  is_hidden  BOOLEAN DEFAULT FALSE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS public.upbo_tasks (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id  UUID REFERENCES public.upbo_members(id) ON DELETE CASCADE,
  type_id    UUID REFERENCES public.upbo_task_types(id) ON DELETE CASCADE,
  quantity   INT DEFAULT 1,
  memo       TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS public.upbo_inquiries (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nickname   TEXT,
  content    TEXT,
  is_read    BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS public.upbo_settings (
  key   TEXT PRIMARY KEY,
  value TEXT
);

ALTER TABLE public.upbo_task_types  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_members     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_tasks       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_inquiries   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_settings    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read task_types"   ON public.upbo_task_types  FOR SELECT USING (true);
CREATE POLICY "public read members"      ON public.upbo_members     FOR SELECT USING (true);
CREATE POLICY "public read tasks"        ON public.upbo_tasks       FOR SELECT USING (true);
CREATE POLICY "public read settings"     ON public.upbo_settings    FOR SELECT USING (true);
CREATE POLICY "public insert inquiries"  ON public.upbo_inquiries   FOR INSERT WITH CHECK (true);
CREATE POLICY "auth all task_types"      ON public.upbo_task_types  FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all members"         ON public.upbo_members     FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all tasks"           ON public.upbo_tasks       FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all settings"        ON public.upbo_settings    FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all inquiries"       ON public.upbo_inquiries   FOR ALL TO authenticated USING (true) WITH CHECK (true);
