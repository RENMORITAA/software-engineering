-- users: 全ユーザーの基本情報
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('requester', 'deliverer', 'store', 'admin')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 依頼者プロフィール
CREATE TABLE IF NOT EXISTS requester_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    default_address_id INTEGER,
    credit_card_info TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 依頼者の住所管理（複数住所対応）
CREATE TABLE IF NOT EXISTS requester_addresses (
    id SERIAL PRIMARY KEY,
    requester_id INTEGER NOT NULL REFERENCES requester_profiles(id) ON DELETE CASCADE,
    label VARCHAR(50) DEFAULT '自宅',
    postal_code VARCHAR(10),
    prefecture VARCHAR(20),
    city VARCHAR(50),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 配達員プロフィール
CREATE TABLE IF NOT EXISTS deliverer_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    resume TEXT,
    work_status VARCHAR(20) DEFAULT 'offline' CHECK (work_status IN ('online', 'offline', 'busy')),
    bank_name VARCHAR(100),
    bank_branch VARCHAR(100),
    bank_account_type VARCHAR(20),
    bank_account_number VARCHAR(20),
    bank_account_holder VARCHAR(100),
    vehicle_type VARCHAR(50),
    license_number VARCHAR(50),
    profile_image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 店舗プロフィール
CREATE TABLE IF NOT EXISTS store_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    store_name VARCHAR(200) NOT NULL,
    description TEXT,
    address VARCHAR(500) NOT NULL,
    postal_code VARCHAR(10),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    phone_number VARCHAR(20),
    business_license VARCHAR(100),
    business_hours VARCHAR(200),
    bank_name VARCHAR(100),
    bank_branch VARCHAR(100),
    bank_account_type VARCHAR(20),
    bank_account_number VARCHAR(20),
    bank_account_holder VARCHAR(100),
    store_image_url VARCHAR(500),
    is_open BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 商品管理テーブル
-- ==========================================

-- 商品カテゴリ
CREATE TABLE IF NOT EXISTS product_categories (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES store_profiles(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 商品
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES store_profiles(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES product_categories(id) ON DELETE SET NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price INTEGER NOT NULL CHECK (price >= 0),
    image_url VARCHAR(500),
    is_available BOOLEAN DEFAULT TRUE,
    stock_quantity INTEGER DEFAULT 0,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 注文管理テーブル
-- ==========================================

-- 注文
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    requester_id INTEGER NOT NULL REFERENCES requester_profiles(id),
    store_id INTEGER NOT NULL REFERENCES store_profiles(id),
    deliverer_id INTEGER REFERENCES deliverer_profiles(id),
    status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN (
        'pending',           -- 注文受付待ち
        'accepted',          -- 店舗が受付
        'preparing',         -- 調理中
        'ready_for_pickup',  -- 受け取り準備完了
        'picked_up',         -- 配達員が受け取り
        'delivering',        -- 配達中
        'delivered',         -- 配達完了
        'cancelled'          -- キャンセル
    )),
    subtotal INTEGER NOT NULL,
    delivery_fee INTEGER NOT NULL DEFAULT 0,
    total_price INTEGER NOT NULL,
    delivery_address VARCHAR(500) NOT NULL,
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    notes TEXT,
    estimated_delivery_time TIMESTAMP,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancel_reason TEXT
);

-- 注文明細
CREATE TABLE IF NOT EXISTS order_details (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    product_name VARCHAR(200) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price INTEGER NOT NULL,
    subtotal INTEGER NOT NULL,
    notes TEXT
);

-- ==========================================
-- 配達管理テーブル
-- ==========================================

-- 配達情報
CREATE TABLE IF NOT EXISTS deliveries (
    id SERIAL PRIMARY KEY,
    order_id INTEGER UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    deliverer_id INTEGER NOT NULL REFERENCES deliverer_profiles(id),
    status VARCHAR(30) NOT NULL DEFAULT 'assigned' CHECK (status IN (
        'assigned',       -- 配達員に割り当て
        'heading_store',  -- 店舗へ向かっている
        'at_store',       -- 店舗に到着
        'picked_up',      -- 商品を受け取った
        'delivering',     -- 配達中
        'arrived',        -- 配達先に到着
        'completed'       -- 完了
    )),
    pickup_time TIMESTAMP,
    delivery_time TIMESTAMP,
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    distance_km DECIMAL(5, 2),
    delivery_fee INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 配達員の位置履歴
CREATE TABLE IF NOT EXISTS delivery_location_history (
    id SERIAL PRIMARY KEY,
    delivery_id INTEGER NOT NULL REFERENCES deliveries(id) ON DELETE CASCADE,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 通知テーブル
-- ==========================================

CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN (
        'order_update',
        'delivery_update', 
        'payment',
        'system',
        'promotion'
    )),
    related_order_id INTEGER REFERENCES orders(id),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 支払い・売上テーブル
-- ==========================================

-- 支払い情報
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER UNIQUE NOT NULL REFERENCES orders(id),
    amount INTEGER NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (payment_status IN (
        'pending', 'completed', 'failed', 'refunded'
    )),
    transaction_id VARCHAR(100),
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 配達員給与
CREATE TABLE IF NOT EXISTS deliverer_payouts (
    id SERIAL PRIMARY KEY,
    deliverer_id INTEGER NOT NULL REFERENCES deliverer_profiles(id),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_deliveries INTEGER NOT NULL DEFAULT 0,
    total_amount INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN (
        'pending', 'processing', 'completed'
    )),
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 店舗売上
CREATE TABLE IF NOT EXISTS store_sales (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES store_profiles(id),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_orders INTEGER NOT NULL DEFAULT 0,
    total_amount INTEGER NOT NULL DEFAULT 0,
    commission_rate DECIMAL(5, 2) DEFAULT 10.00,
    commission_amount INTEGER NOT NULL DEFAULT 0,
    net_amount INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 画像管理テーブル
-- ==========================================

CREATE TABLE IF NOT EXISTS images (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    uploaded_by INTEGER NOT NULL REFERENCES users(id),
    entity_type VARCHAR(50),
    entity_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- レシピ詳細テーブル
-- ==========================================

-- 商品レシピ情報
CREATE TABLE IF NOT EXISTS product_recipes (
    id SERIAL PRIMARY KEY,
    product_id INTEGER UNIQUE NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    preparation_time INTEGER,
    calories INTEGER,
    allergens TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- レシピ材料
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id SERIAL PRIMARY KEY,
    recipe_id INTEGER NOT NULL REFERENCES product_recipes(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    quantity VARCHAR(50),
    display_order INTEGER DEFAULT 0
);

-- レシピ手順
CREATE TABLE IF NOT EXISTS recipe_steps (
    id SERIAL PRIMARY KEY,
    recipe_id INTEGER NOT NULL REFERENCES product_recipes(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    description TEXT NOT NULL,
    image_url VARCHAR(500)
);

-- ==========================================
-- インデックス
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_orders_requester ON orders(requester_id);
CREATE INDEX IF NOT EXISTS idx_orders_store ON orders(store_id);
CREATE INDEX IF NOT EXISTS idx_orders_deliverer ON orders(deliverer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_products_store ON products(store_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_deliverer ON deliveries(deliverer_id);

-- ==========================================
-- テストデータ
-- ==========================================

-- 管理者ユーザー
INSERT INTO users (email, password, role) VALUES 
('admin@stellar.local', '$2b$12$IPWl7OKTMjManRmISrHPiuvv8WW300YNzVowyuAbLSfGBU0maoFJC', 'admin');

-- テスト依頼者
INSERT INTO users (email, password, role) VALUES 
('user1@test.com', '$2b$12$IPWl7OKTMjManRmISrHPiuvv8WW300YNzVowyuAbLSfGBU0maoFJC', 'requester');
INSERT INTO requester_profiles (user_id, name, phone_number) VALUES 
(2, '山田太郎', '090-1234-5678');

-- テスト店舗
INSERT INTO users (email, password, role) VALUES 
('store1@test.com', '$2b$12$IPWl7OKTMjManRmISrHPiuvv8WW300YNzVowyuAbLSfGBU0maoFJC', 'store');
INSERT INTO store_profiles (user_id, store_name, address, phone_number, business_hours) VALUES 
(3, 'テスト食堂', '高知県香美市土佐山田町1-1-1', '0887-52-1234', '10:00-20:00');

-- テスト配達員
INSERT INTO users (email, password, role) VALUES 
('deliverer1@test.com', '$2b$12$IPWl7OKTMjManRmISrHPiuvv8WW300YNzVowyuAbLSfGBU0maoFJC', 'deliverer');
INSERT INTO deliverer_profiles (user_id, name, phone_number, vehicle_type) VALUES 
(4, '佐藤一郎', '090-8765-4321', 'バイク');

-- テスト商品
INSERT INTO products (store_id, name, description, price, is_available) VALUES 
(1, 'カツ丼', '揚げたてサクサクのカツ丼', 850, true),
(1, '親子丼', 'ふわとろ卵の親子丼', 750, true),
(1, 'うどん', '讃岐風うどん', 500, true),
(1, 'カレーライス', '特製スパイスカレー', 800, true);

-- スーパーユーザーの初期データ
INSERT INTO users (email, password, role, is_active)
VALUES ('superuser', '$2b$12$IPWl7OKTMjManRmISrHPiuvv8WW300YNzVowyuAbLSfGBU0maoFJC', 'admin', TRUE)
ON CONFLICT (email) DO NOTHING;

-- スーパーユーザーのプロフィール（必要に応じて）
-- admin用のプロフィールテーブルがないため、requesterとして登録しておくか、admin用のロジックを追加する
-- ここでは便宜上requester_profilesにも追加しておく（エラー回避のため）
INSERT INTO requester_profiles (user_id, name, phone_number)
SELECT id, 'Super User', '000-0000-0000'
FROM users WHERE email = 'superuser'
ON CONFLICT (user_id) DO NOTHING;