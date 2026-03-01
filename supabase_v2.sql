-- ═══════════════════════════════════════════════════════════════
--  DASTYOR v2 — Payment & AI Support Tables
--  Supabase → SQL Editor → Run
-- ═══════════════════════════════════════════════════════════════

-- ─── 1. TRANSACTIONS (To'lovlar tarixi) ──────────────────────
CREATE TABLE IF NOT EXISTS public.transactions (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tx_id       text UNIQUE NOT NULL,          -- DC Pay tranzaksiya ID
  user_id     uuid REFERENCES public.users(id) ON DELETE SET NULL,
  ad_id       uuid REFERENCES public.ads(id)   ON DELETE SET NULL,
  amount      numeric NOT NULL,              -- SM miqdori
  method      text DEFAULT 'ewallet',        -- ewallet|qr|card|cash
  status      text DEFAULT 'pending',        -- pending|success|failed|refunded
  description text,
  merchant_id text,                          -- DC_MERCHANT_ID
  dc_response jsonb DEFAULT '{}'::jsonb,     -- DC Pay API javobi (raw)
  created_at  timestamptz DEFAULT now()
);

-- ─── 2. SUPPORT_CHATS (AI Yordam tarixi) ─────────────────────
CREATE TABLE IF NOT EXISTS public.support_chats (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    uuid REFERENCES public.users(id) ON DELETE SET NULL,
  role       text NOT NULL CHECK (role IN ('user','bot')),
  message    text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- ─── 3. INDEKSLAR ─────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS tx_user_idx     ON public.transactions (user_id);
CREATE INDEX IF NOT EXISTS tx_status_idx   ON public.transactions (status);
CREATE INDEX IF NOT EXISTS tx_created_idx  ON public.transactions (created_at DESC);
CREATE INDEX IF NOT EXISTS chat_user_idx   ON public.support_chats (user_id);
CREATE INDEX IF NOT EXISTS chat_created_idx ON public.support_chats (created_at DESC);

-- ─── 4. RLS — transactions ────────────────────────────────────
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "tx_insert_anon"  ON public.transactions;
CREATE POLICY "tx_insert_anon"
  ON public.transactions FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "tx_select_own"   ON public.transactions;
CREATE POLICY "tx_select_own"
  ON public.transactions FOR SELECT
  USING (true);  -- foydalanuvchi o'z to'lovlarini ko'radi

-- ─── 5. RLS — support_chats ──────────────────────────────────
ALTER TABLE public.support_chats ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "chat_insert_anon" ON public.support_chats;
CREATE POLICY "chat_insert_anon"
  ON public.support_chats FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "chat_select_own"  ON public.support_chats;
CREATE POLICY "chat_select_own"
  ON public.support_chats FOR SELECT
  USING (true);

-- ─── 6. VIEW: To'lovlar statistikasi ─────────────────────────
CREATE OR REPLACE VIEW public.tx_stats AS
SELECT
  method,
  status,
  COUNT(*)            AS count,
  SUM(amount)         AS total_amount,
  AVG(amount)         AS avg_amount,
  MAX(created_at)     AS last_tx
FROM public.transactions
GROUP BY method, status;

-- ─── Natija ✓ ─────────────────────────────────────────────────
-- Jadvallar yaratildi:
--   ✅ transactions   — DC Pay to'lovlari
--   ✅ support_chats  — AI chat tarixi
--   ✅ tx_stats       — statistika view
--
-- Eslatma: ads va users jadvallari avvalgi supabase_setup.sql da bor
