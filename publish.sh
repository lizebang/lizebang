#!/bin/sh
rm -rf public public.tar.gz
hugo
rm public/images/cover.jpg public/images/cover-v1.2.0.jpg
tar -czvf public.tar.gz public