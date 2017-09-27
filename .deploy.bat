hexo generate
cp -R public/* .deploy/LiuKaixin.github.io
cd .deploy/LiuKaixin.github.io
git add .
git commit -m "update"
git push origin hexo