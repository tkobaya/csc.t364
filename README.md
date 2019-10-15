# "システム設計演習" 演習環境用 Docker 

このリポジトリは CSC.T374 Workshop on System Design の2019年度ビッグデータ解析テーマの演習環境をDockerで構築するためのファイル群です．
jupyter/datascience-notebook(https://hub.docker.com/r/jupyter/datascience-notebook) を元に "1001_テキストマイニング環境構築.pdf" で指示のあったソフトウェアを使えるようにしてあります．

現在のところ，以下をインストールした Ubuntu 18.04.2 LTS のイメージが構築されます．
- Jupyter 4.4.0, JupyterLab 1.1.3 
- python 3.7.3
- natto-py (version 0.9.0, pipでinstall)
- MeCab (version 0.996, UTF-8)
- MeCab ipadic (utf8)
- Neologism dictionary for MeCab (mecab-ipadic-neologd) 最新版
- Mecab NAIST JDIC 0.6.3b-20111013
- CRF++-0.58
- CaboCha (version 0.69)

# 使い方
## 準備 (初回のみ)

- Dockerをインストールする
  - https://www.docker.com/get-started から Docker Desktopをダウンロード (要ユーザ登録)
  - 日本語化プロジェクトによる和訳 http://docs.docker.jp/engine/installation/toc.html
- このリポジトリを適当なフォルダに clone する
- ````docker-compose.yml```` を編集する
  - ````volumes:````の次の行を Mac/Windowsの場合のいずれかをコメントアウトし，
    自分のユーザ名に書き換えてください．
  - Dockerコンテナ内の /home/jovyan/work というディレクトリを，Dockerが実行されている計算機のどのディレクトリにマップするかを設定します．
    JupyterLabからアクセスするファイルの置き場として使います．
- cloneしたフォルダで以下を実行
  - ````% docker-compose up````
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
- コンテナイメージが完成した後にコンテナが起動し以下のようなメッセージが表示されます
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
 
## 起動方法
- `% docker-compose up -d` と -d オプションをつけると，バッググランドで実行されます．
   - バックグランドで実行した場合の終了には `% docker-compose kill` と実行してください．
   - 終了せずに複数回 ````% docker-compose up -d ```` をすると複数のインスタンスが起動したままとなり，ポートを確保できないなどの警告がでます．
   ````% docker-compose ps ```` で起動しているインスタンスがないか確認し不要なインスタンスは kill してください．
- コンテナにログインして直接pythonやMeCab，CaboChaなどを実行したい場合は，
  ````% docker-compouse exec jupyterlab bash````
  で jupyterlab コンテナにログインすることができます．
  
## Memo
- mecabrc の場所は ````/etc/mecabrc```` です．
- 各種MeCab用の辞書は以下のように，`配布資料と異なるパス`にインストールされていますので注意してください．(mecabrcにコメントアウトして記載してあります.)
````
/usr/lib/mecab/dic/ipadic-utf8
/usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd
/usr/lib/x86_64-linux-gnu/mecab/dic/naist-jdic
````
