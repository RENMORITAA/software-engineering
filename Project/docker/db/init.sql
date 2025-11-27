-- テーブル作成
CREATE TABLE IF NOT EXISTS todos (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100),
    is_done BOOLEAN DEFAULT FALSE
);

-- テストデータ挿入
INSERT INTO todos (title, is_done) VALUES ('講義の課題を終わらせる', false);
INSERT INTO todos (title, is_done) VALUES ('Docker構築成功！', true);