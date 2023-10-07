#!/usr/bin/env bash

echo "create directories"
mkdir -p ~/bin
mkdir -p ~/android/lineage 
mkdir -p ~/android/ccache/lineage
mkdir -p ~/android/lineage/.repo/local_manifests

echo "download last repo version"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

#echo "configure git" # - replace user name and email with your own ones
#echo "configure git" # - replace user name and email with your own ones
#git config --global user.name "Your Name"
#git config --global user.email "yourmail@email.com"
#git config --global color.ui true #this stops the repo init colorization prompt

echo "initiate the LineageOS repo"
cd ~/android/lineage
~/bin/repo init -u https://github.com/2spirit/android.git -b lineage-20.0 --git-lfs

echo "clone local manifest"
wget https://raw.githubusercontent.com/2spirit/manifests/main/sweet_los-20_2spirit_roomservice.xml -P ~/android/lineage/.repo/local_manifests/

echo "sync the source"
~/bin/repo sync -j$(nproc --all)

echo "Copy missing google lib for keyboard swipe"
mkdir -p ~/android/lineage/out/target/product/sweet/product/lib64/
wget https://raw.githubusercontent.com/2spirit/manifests/main/libjni_latinimegoogle.so -P ~/android/lineage/out/target/product/sweet/product/lib64/

echo "enable ccache"
export USE_CCACHE=1 && export CCACHE_DIR=~/android/ccache/lineage && export CCACHE_EXEC=/usr/bin/ccache && ccache -M 100G

echo "enable MicroG"
export WITH_GMS=true

echo "setup build environment"
source build/envsetup.sh
croot

echo "prepare sweet for building"
lunch lineage_sweet-userdebug

echo "start building"
mka bacon -j$(nproc --all)

