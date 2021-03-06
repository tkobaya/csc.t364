# "システム設計演習" 演習環境用 Docker 

このリポジトリは CSC.T364 Workshop on System Design の2019年度ビッグデータ解析テーマの演習環境をDockerで構築するためのファイル群です．
jupyter/datascience-notebook(https://hub.docker.com/r/jupyter/datascience-notebook) を元に "1001_テキストマイニング環境構築.pdf" で指示のあったソフトウェアを使えるようにしてあります．

2019/10/18の時点では，以下をインストールした Ubuntu 18.04.2 LTS のイメージが構築されます．
- Baseコンテナ jupyter/datascience-notebook
  - Digest: sha256-dc2b7aac066f101107128d825d51b56cb1abd5bcbbc2b5f2ec0a03c3114f75e6
  - Jupyter 4.4.0, JupyterLab 1.1.3 
  - python 3.7.3
- MeCab (version 0.996, UTF-8)
- MeCab ipadic (utf8)
- Neologism dictionary for MeCab (mecab-ipadic-neologd) 最新版
- Mecab NAIST JDIC 0.6.3b-20111013
- CRF++-0.58
- CaboCha (version 0.69) + python module for CaboCha
- GraphViz (version 2.40.1-2) 
- python module
  - natto-py (version 0.9.0, pipでinstall)
  - dtreeviz (version 0.6, pipでinstall)
  - graphviz (version 0.13, pipでinstall)
  - gensim (version 3.8.1, pipでinstall)
- ※ gephi はGUIツールのためインストールするようになっていません．各自 https://gephi.org/users/download/ から利用しているホストOS用のものをダウンロード・インストールして，Dockerコンテナ側で生成した gexf ファイルを読み込んで確認するようにしてください．

# 使い方
## 準備 (初回のみ)
- Dockerをインストールする
  - (2020/Mar/17 追記) 2020年3月にWindows Subsystem for Linux 2 (WSL-2) 用のDocker Desktopがリリースされました．Hyper-V
   を使わないので，Windows 10 Home でも使えます．https://www.docker.com/blog/docker-desktop-for-windows-home-is-here/ 
  - Windowsの場合，仮想環境を利用できる必要があります．Windows 10 Pro, Education を使っている場合はHyper-V が使えるので問題ありませんが，Windows 10 Home を使っている人は以下などを参照し仮想環境を用意してください．
    - https://qiita.com/idani/items/fb7681d79eeb48c05144
  - https://www.docker.com/get-started から Docker Desktopをダウンロード (要ユーザ登録)
    - 日本語化プロジェクトによる和訳 http://docs.docker.jp/engine/installation/toc.html
- このリポジトリを適当なフォルダに clone する
- ````docker-compose.yml```` を編集する
  - ````volumes:````の次の行を Mac/Windowsの場合のいずれかをコメントアウトし，
    自分のユーザ名に書き換えてください．
  - Dockerコンテナ内の /home/jovyan/work というディレクトリを，ホスト(Dockerが実行されている計算機)のどのディレクトリにマップするかを設定します．
    JupyterLabからアクセスするファイルの置き場として使います．コンテナ側のパス /home/jovyan/work は変更しないでください．
  - (例) ホスト側(Windows) の ````C:\Users\tkobaya\bda-work```` を コンテナ側の ````/home/jovyan/work```` と見せたい場合は
    ````- "/C/Users/tkobaya/bda-work:/home/jovyan/work" ```` 
    と変更します．
  - コンテナイメージを用意する．*以下の2つの方法* を用意しています．
    - A) 構築済みコンテナを使う : 〇 構築にかかるトラブル回避・帯域＆時間削減ができる．× GitHub でアクセストークンを作る必要がある
    - B) 自分で Dockerfile から構築する : 〇自分でコンテナを改良できる．× 構築に時間がかかる (それほど手間ではないはずです) 
    
### A) 構築済みコンテナイメージを使う準備をする (Defaultではこちら)
※ コンテナイメージを自分で構築する場合には，こちらの作業は不要です．

docker が GitHubのパッケージレジストリにアクセスできるように設定が必要です．
(参考：https://help.github.com/ja/github/managing-packages-with-github-packages/configuring-docker-for-use-with-github-packages)
以下の手順で Docker が docker.pkg.github.com にアクセスするための認証情報を設定します．
- GitHubで Personal access token を作る
  - 注意：Personal access token は設定した権限に対してパスワードと同等の働きをするので慎重に利用・管理すること．
  - Noteには後から用途を識別できる名前 (access-packages など)を入力する
  - https://github.com/settings/tokens で `Generate new token` をクリックし，repo と read:packages にチェックを入れる
  - ページ下部の`Generate Token` をクリックし，生成する
  - 次のページで表示される文字列が Personal access token．再表示できないので安全な場所にメモを取るなどする．
- docker login で，docker.pkg.github.com にログインする
````
$ docker login docker.pkg.github.com -u <USERNAME> -p <TOKEN>
````
  - `<USERNAME>` はGithubのアカウント．`<TOKEN>` はPersonal Access Tokenを指定してください．

- 以降 `docker pull docker.pkg.github.com/(リポジトリ名)/イメージタグ` でGitHubのパッケージレジストリ上のイメージが pull できます．例えば，コンテナを更新する場合には以下を実行することで最新版のコンテナイメージがダウンロードされます．
````
$ docker pull docker.pkg.github.com/tkobaya/csc.t364/csc_t364_jupyterlab:latest
````

### B)コンテナイメージを構築する
※ 構築済みコンテナイメージを使う場合には，こちらの作業は不要です．
- コンテナイメージを構築する
  - コマンドプロンプト(Windows)またはConsole(Mac)を開き cloneしたフォルダで ````% docker-compose build```` と実行します．
  - 注意：初回に 10GB程度のファイルがダウンロードされます．インターネットへの接続環境が良いところで作業することを勧めます．
  - 初回のみコンテナイメージ作成で各種ファイルのダウンロードに加え，Mecab, Ipadic, CaboCha等のコンパイルがあるため大分時間がかかります．気長に待ちましょう
- コンテナイメージが完成すると，mecab, cabocha を実行した結果が表示されます．講義資料と同じ出力になっていない場合は小林かTAに相談してください．
````
Step 17/18 : RUN set -x &&     : === Test execution of Mecab === &&     echo "東工大は良いところ" | mecab
...
東工大  名詞,固有名詞,組織,*,*,*,東工大,トウコウダイ,トーコーダイ,,
は      助詞,係助詞,*,*,*,*,は,ハ,ワ,,
良い    形容詞,自立,*,*,形容詞・アウオ段,基本形,良い,ヨイ,ヨイ,よい/良い,
ところ  名詞,非自立,副詞可能,*,*,*,ところ,トコロ,トコロ,,
EOS
+ : === Test execution of Mecab ===
....
Step 18/18 : RUN set -x &&     : === Test execution of CaboCha === &&     echo "東工大は良いところ" | cabocha
+ : === Test execution of CaboCha ===
+ cabocha
+ echo 東工大は良いところ
東工大は---D
      良い-D
      ところ
EOS
....
Successfully built 96ade3c5040a
Successfully tagged bda2019_jupyterlab:latest
````
- 上記の表示がされない場合はコンテナ構築に失敗しています．小林またはTAに相談してください．
 
## 起動・終了方法
- コマンドプロンプト(Windows)またはConsole(Mac)を開き cloneしたフォルダで `% docker-compose up` と実行してください．
  - コンテナが起動し以下のようなメッセージが表示されます
````
jupyterlab_1  | [I 13:47:47.412 LabApp] Writing notebook server cookie secret to /home/jovyan/.local/share/jupyter/runtime/notebook_cookie_secret
jupyterlab_1  | [I 13:47:47.751 LabApp] JupyterLab extension loaded from /opt/conda/lib/python3.7/site-packages/jupyterlab
jupyterlab_1  | [I 13:47:47.751 LabApp] JupyterLab application directory is /opt/conda/share/jupyter/lab
jupyterlab_1  | [I 13:47:47.753 LabApp] Serving notebooks from local directory: /var/tmp
jupyterlab_1  | [I 13:47:47.753 LabApp] The Jupyter Notebook is running at:
jupyterlab_1  | [I 13:47:47.753 LabApp] http://595cfce668c1:8888/?token=<token>
jupyterlab_1  | [I 13:47:47.753 LabApp]  or http://127.0.0.1:8888/?token=<token>
jupyterlab_1  | [I 13:47:47.753 LabApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
jupyterlab_1  | [C 13:47:47.757 LabApp]
jupyterlab_1  |
jupyterlab_1  |     To access the notebook, open this file in a browser:
jupyterlab_1  |         file:///home/jovyan/.local/share/jupyter/runtime/nbserver-14-open.html
jupyterlab_1  |     Or copy and paste one of these URLs:
jupyterlab_1  |         http://595cfce668c1:8888/?token=<token>
jupyterlab_1  |      or http://127.0.0.1:8888/?token=<token>
````
- ブラウザを開いて 上記で表示された ````http://localhost:8888/?token=<token>```` にアクセスすると，JupyterLab が使用できます
  - ※ ````<token>````の部分は各自の環境で異なります．ブックマークしておくと便利です．
- 終了するには `Ctrl + C` で ````docker-compose```` を終了してください．
- コンテナにログインして直接pythonやMeCab，CaboChaなどを実行したい場合は，別のコマンドプロンプト(Windows)またはConsole(Mac)を開き
  ````% docker-compose exec jupyterlab bash````
  を実行することで jupyterlab コンテナにログインすることができます．
  - 配布している ````docker-compose.yml```` では root でログインするようになっており sudo コマンドなど管理者権限が必要な操作も可能にしてあります．
  - pythonコマンドは /opt/conda/bin/python が実行されるように path が設定されています．/usr/bin/python は version 2.7 のままです．shebang (スクリプトファイルの先頭行)を書く際には気を付けてください．

## Dockerイメージの更新
Dockerファイルにソフトウェアの更新，プログラムの追加などの変更があり，イメージを更新(再構築)する必要がある場合は以下のコマンドを実行してください．
Dockerファイルに変更があった箇所以降の構築コマンドが再実行されます，(増分ビルドなので初回よりは短い時間で構築が終わります．)
````
% git pull 
% docker-compose build
````
# TIPS
## バッググランド実行
- `% docker-compose up -d` と -d オプションをつけると，バッググランドで実行されます．
   - `% docker-compose ps` で現在実行中のインスタンスの情報が表示できます．
   - バックグランドで実行した場合の終了には `% docker-compose kill` と実行してください．
   - 終了せずに複数回 ````% docker-compose up -d ```` をすると複数のインスタンスが起動したままとなり，ポートを確保できないなどの警告がでます．
   ````% docker-compose ps ```` で起動しているインスタンスがないか確認し不要なインスタンスは kill してください．

## CaboChaの辞書 変更
- mecabrc の場所は ````/etc/mecabrc```` です．
- 各種MeCab用の辞書は以下のように，`配布資料と異なるパス`にインストールされていますので注意してください．(mecabrcにコメントアウトして記載してあります) → 現在は配布資料と同じパスで参照できるようにリンクを貼ってあるので講義資料通りの記述でも動作します
````
/usr/lib/mecab/dic/ipadic-utf8
/usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd
/usr/lib/x86_64-linux-gnu/mecab/dic/naist-jdic
````
# Known Issues
- matplotlib で日本語が表示できない場合があります．
  - 以下のpythonコードをjupyterlab等で実行することで、フォントに関するキャッシュを再構築することで日本語表示ができるようになります.
  - jupyterlabの場合にはKernelの再起動が必要です.
```` 
import matplotlib
matplotlib.font_manager._rebuild()
````
# Release Note
- 2019-11-14 (rel-1.2)
  - GitHub Actions で イメージの自動ビルドを始めたので，初期設定ではそちらを使用することに変更しました．
- 2019-11-06 (rel-1.1)
  - 11/1の講義資料で利用する gensim をインストールするようになりました．
- 2019-10-18
  - GraphViz と pythonからGraphViz を呼び出すモジュール graphviz 及び dtreeviz をインストールするようになりました．
- 2019-10-16 (rel-1.0)
  - pythonから CaboCha を利用するためのモジュールもインストールするようになりました．Docker image をビルドする際にテスト実行しています．
  - matplotlib で日本語が豆腐になる問題を部分的に解決しました．Noto フォントを入れて ````font_manager._rebuild()```` を読んでキャッシュをリビルドしています. 初回実行では豆腐になったままですが，Kernel を再起動すれば日本語が表示されます．
  - MeCab用の辞書を，環境構築資料と同じパスで参照できるようにしました．
- 2019-10-15
  - 公開開始

