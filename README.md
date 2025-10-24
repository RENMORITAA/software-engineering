# ソフトウェア工学

このリポジトリは、Git/GitHubを使用してソフトウェア工学の開発を行うためのものである。  


## 最重要

| 手順 | コマンド | 説明 |
|------|-----------|------|
| ① | `git pull` | 最新の状態を取得（自動でrebase実行） |
| ② | 作業 | ファイルの編集や修正を行う |
| ③ | `git add .` | 変更したファイルをステージングエリアに追加 |
| ④ | `git commit -m "変更内容"` | 変更内容をコミットとして確定 |
| ⑤ | `git push` | GitHubリポジトリへアップロード |

この手順に従うことで、基本的には問題なく作業できる。  
**「pull → edit → add → commit → push」**の順序を守ることで、衝突をほぼ完全に回避できる。

---

## 1. 初回設定（最初に1回のみ実施）

###  ユーザー名とメールアドレスの登録
```bash
git config --global user.name "あなたのGitHubユーザー名"
git config --global user.email "あなたのGitHub登録メールアドレス"
```

###  衝突を回避する推奨設定（自動でrebaseを実行）
```bash
git config --global pull.rebase true
```

この設定を行うことで、今後の `git pull` コマンドは自動的に  
`git pull --rebase` と同じ動作となる。  
これにより、履歴が整理され、衝突がほとんど発生しなくなる。

---

##  2. リポジトリのクローン作成

初回作業時のみ実行すること：
```bash
git clone git@github.com:RENMORITAA/software-engineering.git
cd software-engineering
```

---

##  3. 日常の作業手順（衝突を避ける推奨フロー）

| 手順 | コマンド | 説明 |
|------|-----------|------|
| ① | `git pull` | 最新の状態を取得（自動でrebase実行） |
| ② | 作業 | ファイルの編集や修正を行う |
| ③ | `git add .` | 変更したファイルをステージングエリアに追加 |
| ④ | `git commit -m "変更内容"` | 変更内容をコミットとして確定 |
| ⑤ | `git push` | GitHubリポジトリへアップロード |

この手順に従うことで、基本的には問題なく作業できる。  
**「pull → edit → add → commit → push」**の順序を守ることで、衝突をほぼ完全に回避できる。

---

##  4. よく使用するコマンド一覧

| コマンド | 用途・説明 |
|-----------|------|
| `git status` | 現在の作業状況を確認 |
| `git add .` | すべての変更ファイルをステージングエリアに追加 |
| `git commit -m "メッセージ"` | 変更内容をコミットとして確定 |
| `git push` | GitHubリポジトリに変更を送信 |
| `git pull` | 最新の変更を取得（rebase設定済み） |
| `git log` | コミット履歴を表示 |
| `git branch` | ブランチの一覧を表示 |
| `git checkout -b ブランチ名` | 新しいブランチを作成して切り替え |

---

##  5. トラブルシューティング

###  「Permission denied (publickey)」エラーの場合
このエラーは、SSH鍵がGitHubに登録されていないことが原因である。  
以下の手順で解決すること：
```bash
ssh-keygen -t ed25519 -C "あなたのメールアドレス"
cat ~/.ssh/id_ed25519.pub
```
表示された文字列をコピーし、GitHubの  
**Settings → SSH and GPG keys → New SSH key** に貼り付けて登録すること。

---

### 「error: failed to push some refs」エラーの場合
このエラーは、他の開発者が先にpushを行った場合に発生する。  
以下のコマンドで解決できる：
```bash
git pull --rebase
git push
```

---

###  rebase実行中にコンフリクト（衝突）が発生した場合
稀にコンフリクトが発生することがある。  
Gitが指摘するファイルを開き、  
`<<<<<<<`, `=======`, `>>>>>>>` の部分を手動で修正した後、以下のコマンドを実行すること：

```bash
git add .
git rebase --continue
```

---

## 🔄 6. リポジトリの復旧方法

万が一、ローカルリポジトリに問題が発生した場合は、  
バックアップを作成してから再度クローンすることを推奨する：

```bash
cd ..
rm -rf software-engineering
git clone git@github.com:RENMORITAA/software-engineering.git
cd software-engineering
```

---

##  7. 基本作業フローのまとめ（重要）

以下の手順を覚えておけば、安全にGitを使用できる：

```
# 衝突を避ける推奨作業フロー
git pull        ← 最新の変更を取得（rebase自動実行）
# ↓ ここでファイルの編集作業を行う
git add .
git commit -m "変更内容の説明"
git push
```