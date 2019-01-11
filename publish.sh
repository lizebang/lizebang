#!/bin/sh
rm -rf public public.tar.gz
hugo
rm public/images/cover.jpg public/images/cover-v1.2.0.jpg
tar -czvf public.tar.gz public
scp public.tar.gz root@lizebang.top:/root/public.tar.gz
ssh root@lizebang.top "tar -zxvf /root/public.tar.gz && rm -rf /root/lizebang.top/blog/* && mv /root/public/* /root/lizebang.top/blog && rm -rf /root/public /root/public.tar.gz"
rm public.tar.gz
