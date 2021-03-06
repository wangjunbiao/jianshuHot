#!/bin/bash
# File Name: start.sh
# Author: JackeyGao
# mail: junqi.gao@shuyun.com
# Created Time: 三  1/ 6 15:33:06 2016

cd $(dirname $0)
source /etc/profile
source ~/.virtualenvs/spider/bin/activate

echo "删除旧数据 - note"
python -c "from jianshu.db import delete_note; delete_note()"

echo "删除旧数据 - notef"
find ./output/markdown -type f -delete

echo "删除旧数据 - image"
python -c "from jianshu.db import delete_image; delete_image()"

echo "删除旧数据 - imagef"
find ./output/images -type f -delete

echo "重新抓取中 - note"
scrapy crawl jianshu_hot --nolog

echo "重新抓取中 - image"
python -c "from jianshu.image import request_images; request_images()"

echo "生成markdown"
python -c "from jianshu.book import gen_markdown; gen_markdown()"

echo "生成gitbook"
python -c "from jianshu.book import gen_book; gen_book()"

## 自定义邮箱服务器
## YOURKINDLE_MAIL_ADDRESS="xxxxx@kindle.cn"
YOURKINDLE_MAIL_ADDRESS="renzhn@qq.com"
YOUR_SEND_MAIL_USERNAME="va2897@163.com"
YOUR_SEND_MAIL_SECRET='alacrity'
MOBI_BOOK_PATH=output/books/jianshu_hot-$(date "+%Y%m%d").mobi
cp output/book.mobi $MOBI_BOOK_PATH

echo "发送邮件"
## 定义sendemail命令地址
sendEmail -o tls=no -s smtp.163.com -t $YOURKINDLE_MAIL_ADDRESS -u "简书热门$(date "+%Y%m%d")" -m "简书热门$(date "+%Y%m%d")" -xu $YOUR_SEND_MAIL_USERNAME -xp $YOUR_SEND_MAIL_SECRET -f $YOUR_SEND_MAIL_USERNAME -a $MOBI_BOOK_PATH
