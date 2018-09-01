#!/bin/sh
rm -rf public public.zip
hugo
rm public/images/cover.jpg public/images/cover-v1.2.0.jpg
zip public.zip -r public