# 新規クライアント用 複製手順

このカレンダーアプリを新しいクライアント向けに複製するときの手順です。
クライアントごとに「Supabaseプロジェクト」と「GitHubリポジトリ」を1セット作ります。

## 1. 新しいSupabaseプロジェクトを作成する

1. https://supabase.com/dashboard を開く
2. **New Project** をクリック
3. 入力項目:
   - **Name**: クライアント名など、わかりやすい名前
   - **Database Password**: 任意の強いパスワード(自分で控えておく。サイトのログインとは別物です)
   - **Region**: `Northeast Asia (Tokyo)`
4. **Create new project** をクリックし、1〜2分待つ

## 2. schema.sql を実行する

1. 左メニューの **SQL Editor** を開く
2. 新しいクエリタブを開く(「+」ボタン)
3. このリポジトリの [`schema.sql`](schema.sql) の中身を全部コピーして貼り付け、**Run**
   - ※ブラウザの自動翻訳がオンになっていると、コード中の英単語まで日本語に翻訳されてSQLが壊れることがあります。翻訳はオフにしてから貼り付けてください。
4. エラーが出た場合はもう一度Runを試す、それでもダメならページを再読み込みしてから再実行

## 3. 自分のアカウントで管理者登録する

Claudeが新しいサイト(GitHub Pages)を用意したら:

1. 新しいサイトの `signup.html` から、自分のメールアドレスでサインアップ
2. Supabaseの **SQL Editor** で以下を実行(メールアドレスは自分のものに置き換える)

   ```sql
   update profiles set role = 'admin', approved = true where email = 'あなたのメールアドレス';
   ```

3. サイトに戻ってログインし直すと、管理者としてカレンダーと管理者ページが使えます

## 4. 接続情報をClaudeに渡す

1. Supabaseの **Project Settings → API** を開く
2. 以下の2つをコピーする
   - **Project URL**(`https://xxxxx.supabase.co` の形式)
   - **Publishable key**(`sb_publishable_...` から始まる文字列)
3. Claudeに「新しいクライアント用に複製して」と伝え、この2つを渡す

## 5. Claude側で行われること

- 新しいGitHubリポジトリを作成(`gotos-code`アカウント配下)
- 今の画面一式(ログイン・サインアップ・カレンダー・管理者ページ・使い方ページ)をそのままコピーして、渡された接続情報に差し替えてpush
- GitHub Pagesを有効化し、公開URLを発行

## 6. 最終確認

- 発行されたURL(`https://gotos-code.github.io/<新リポジトリ名>/`)にアクセス
- ログイン・予定の登録ができるか確認
- 必要に応じて、クライアント側の担当者用にサインアップ〜承認の流れを案内する
