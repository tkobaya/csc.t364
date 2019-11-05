FROM jupyter/datascience-notebook

LABEL maintainer="Takashi Kobayashi <tkobaya@c.titech.ac.jp>"

RUN pip install jupyterlab
RUN pip install natto-py
RUN jupyter serverextension enable --py jupyterlab

USER root
WORKDIR /var/tmp

RUN set -x && \
    : Update package list and upgrade installed packages && \
#    apt-get update && apt-get -y upgrade 
    apt-get update 

RUN set -x && \
    : Install Mecab and IPA dictionary && \
    apt-get -y install \ 
         mecab libmecab-dev \
         mecab-ipadic-utf8 \
	 file 

RUN set -x && \
    : Install ipadic-neologd && \
    git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
    cd mecab-ipadic-neologd && \
    ./bin/install-mecab-ipadic-neologd -n -y -a 

RUN set -x && \ 
    : Install naist-jdic && \
    wget https://ja.osdn.net/dl/naist-jdic/mecab-naist-jdic-0.6.3b-20111013.tar.gz && \
    tar xvfz mecab-naist-jdic-0.6.3b-20111013.tar.gz && \
    cd mecab-naist-jdic-0.6.3b-20111013 && \
    ./configure --with-charset=utf8 && \
    make install

RUN set -x && \ 
    : Modify default dictionary to naist-jdic && \
    cp -f /etc/mecabrc /etc/mecabrc- && \
    grep -v dicdir /etc/mecabrc- > /etc/mecabrc && \
    echo ";dicdir = /var/lib/mecab/dic/debian" >> /etc/mecabrc && \ 
    echo ";dicdir = /usr/lib/mecab/dic/ipadic-utf8" >> /etc/mecabrc && \ 
    echo ";dicdir = /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd" >> /etc/mecabrc && \ 
    echo "dicdir = /usr/lib/x86_64-linux-gnu/mecab/dic/naist-jdic" >>  /etc/mecabrc 

RUN set -x && \ 
    : Install CRF++ && \
    wget "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ" -O CRF++-0.58.tar.gz && \
    tar zxf CRF++-0.58.tar.gz && \
    cd CRF++-0.58 && \
    ./configure && make && make install && \
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/lib.conf && \
    ldconfig

RUN set -x && \ 
    : Install CaboCha  && \
    : Obtain cabocha-0.69.tar.bz2. thanks to https://qiita.com/namakemono/items/c963e75e0af3f7eed732 && \
    curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU" > /dev/null && \
    CODE="$(awk '/_warning_/ {print $NF}' /tmp/cookie)" && \ 
    curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${CODE}&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU" -o cabocha-0.69.tar.bz2 && \
    tar jxf cabocha-0.69.tar.bz2 && \ 
    cd cabocha-0.69 && \
    ./configure --with-mecab-config=`which mecab-config` --with-charset=utf8 && \
    make && make install && ldconfig 

RUN set -x && \ 
    : Install python module for CaboCha && \
    cd cabocha-0.69/python && \
    python ./setup.py install && \
    wget https://gist.githubusercontent.com/nosada/9530569/raw/f1d87329d85d592751c7caca4d71a22fffd318ff/test.patch && \
    patch  < test.patch && \ 
    python ./test.py 

RUN set -x && \
    mkdir -p /usr/local/lib/mecab/dic && \
    cd /usr/local/lib/mecab/dic && \
    ln -s /usr/lib/x86_64-linux-gnu/mecab/dic/naist-jdic && \
    ln -s /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd 

RUN set -x && \
    apt-get install fonts-noto-cjk

USER jovyan
WORKDIR /home/jovyan/work

RUN set -x && \
    : update font cache && \
    mv /home/jovyan/.cache/matplotlib/fontlist-v310.json{,-} ; exit 0 && \
    echo "import matplotlib.font_manager as fm; fm._rebuild()" | /opt/conda/bin/python

## rel-1.1
USER root
WORKDIR /var/tmp

RUN set -x && \
    apt-get -y install graphviz

USER jovyan
WORKDIR /home/jovyan/work

RUN set -x && \
    pip install dtreeviz && \
    pip install gensim

## 

USER jovyan
WORKDIR /home/jovyan/work

RUN set -x && \ 
    : === mecab -D === && \ 
    mecab -D; exit 0 
RUN set -x && \ 
    : === Test execution of Mecab === && \ 
    echo "東工大は良いところ" | mecab  
RUN set -x && \ 
    : === Test execution of CaboCha === && \ 
    echo "東工大は良いところ" | cabocha

## ブラウザを開いてhttp://localhost:10000/?token=<token>にアクセスする．
## <token>の値はdocker runした時にコンソールに表示されるものを使う．
