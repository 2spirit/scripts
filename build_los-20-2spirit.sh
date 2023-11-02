#!/usr/bin/env bash

#echo "setup the build environment"
#wget https://raw.githubusercontent.com/2spirit/scripts/master/setup_build_envirionment-ubuntu.sh
#chmod +x setup_build_envirionment-ubuntu.sh
#./setup_build_envirionment-ubuntu.sh
#rm setup_build_envirionment-ubuntu.sh

echo "create directories"
mkdir -p ~/bin
mkdir -p ~/android/lineage 
mkdir -p ~/android/ccache/lineage

echo "download last repo version"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

echo "setup git config"
git config --global user.name "build"
git config --global user.email "build@example.com"
git config --global color.ui true

echo "go to the working directory"
cd ~/android/lineage

echo "initiate the LineageOS repo"
~/bin/repo init -u https://github.com/2spirit/android.git -b lineage-20.0 --git-lfs

echo "clone local manifest"
mkdir -p ~/android/lineage/.repo/local_manifests
wget https://raw.githubusercontent.com/2spirit/manifests/main/sweet_los-20_2spirit_roomservice.xml -O ~/android/lineage/.repo/local_manifests/roomservice.xml

echo "sync the source"
#~/bin/repo sync -j$(nproc --all)
~/bin/repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

echo "Add Leica Camera"
git clone https://gitlab.com/unsatifsed27/miuicamera.git -b leica vendor/xiaomi/sweet-miuicamera
sed -i 's/"Aperture", //g' vendor/xiaomi/sweet-miuicamera/common/Android.bp

echo "Copy missing google lib for keyboard swipe"
mkdir -p ~/android/lineage/out/target/product/sweet/product/lib64/
wget https://raw.githubusercontent.com/2spirit/scripts/main/libjni_latinimegoogle.so -O ~/android/lineage/out/target/product/sweet/product/lib64/libjni_latinimegoogle.so

#echo "sign build"
#wget https://raw.githubusercontent.com/2spirit/scripts/main/gen_key -O ~/bin/gen_key
#chmod +x ~/bin/gen_key
#~/bin/gen_key
#sed -i "1s;^;PRODUCT_DEFAULT_DEV_CERTIFICATE := user-keys/releasekey\nPRODUCT_OTA_PUBLIC_KEYS := user-keys/releasekey\n\n;" "vendor/lineage/config/common.mk"

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

