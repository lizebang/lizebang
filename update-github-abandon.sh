#!/bin/bash

echo "rm"

rm -rf .DS_Store
rm -rf public

echo "init"

hugo
cd public
git init
git remote add origin https://github.com/lizebang/lizebang.github.io
git status

echo "commit"

git add .gitignore
echo "*.DS_Store" >> .gitignore
git add README.md
echo "# lizebang.github.io\nMy Blog: [https://lizebang.github.io](https://lizebang.github.io)" >> README.md
git add --all
git stage *
git commit -a -m "refresh"
git status

echo "gc"

git gc

echo "push"

git push --force origin HEAD
git status

cd ..
git add .
git commit -m "update"
git push

echo "done"
