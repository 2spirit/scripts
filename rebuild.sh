#!/usr/bin/env bash

echo "go to the working directory"
cd ~/android/lineage

echo "make clean"
source build/envsetup.sh
make clean

echo "clone local manifest"
mkdir -p ~/android/lineage/.repo/local_manifests
wget https://raw.githubusercontent.com/2spirit/manifests/main/sweet_los-20_2spirit_roomservice.xml -O ~/android/lineage/.repo/local_manifests/roomservice.xml

echo "sync the source"
#~/bin/repo sync -j$(nproc --all)
~/bin/repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

echo "Copy missing google lib for keyboard swipe"
mkdir -p ~/android/lineage/out/target/product/sweet/product/lib64/
wget https://raw.githubusercontent.com/2spirit/scripts/main/libjni_latinimegoogle.so -O ~/android/lineage/out/target/product/sweet/product/lib64/libjni_latinimegoogle.so

echo "create symlink to user-keys"
ln -sf ~/user-keys

echo "enable ccache"
export USE_CCACHE=1 && export CCACHE_DIR=~/android/ccache/lineage && export CCACHE_EXEC=/usr/bin/ccache && ccache -M 50G

echo "enable MicroG"
export WITH_GMS=true

echo "setup build environment"
source build/envsetup.sh
croot

echo "prepare sweet for building"
lunch lineage_sweet-userdebug

echo "start building"
mka bacon -j$(nproc --all)

