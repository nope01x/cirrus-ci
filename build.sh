#!/bin/bash

res_sync() {
    rm -rf .git && rbebb
    msgtl -t "Build Started ( <a href='https://cirrus-ci.com/task/${CIRRUS_TASK_ID}'>View on Cirrus CI</a> )"

    repo init --depth=1 -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs

    git clone --depth=1 https://github.com/rducks/rom.git rdx -q

    mkdir -p .repo/local_manifests
    mv rdx/s/rmx*.xml .repo/local_manifests/roomservice.xml

    mkdir -p ~/.config
    mv rdx/configs/* ~/.config

    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --prune || { msgtl -t "Repo sync failed!"; exit 1; }

    # patch -p1 < rdx/q/0001*
    # patch -p1 < rdx/q/0002*
    # patch -p1 < rdx/q/0003*

    # patch -p1 < rdx/q/0006*
    # patch -p1 < rdx/q/0007*
    # patch -p1 < rdx/q/0008*

}

build() {    
    source build/envsetup.sh
    lunch lineage_RMX2185-userdebug
    mka bacon -j$(nproc --all) 2>&1 | tee build.log
    build_status=${PIPESTATUS[0]}   
    if [ $build_status -eq 0 ]; then
        msgtl -t "Build completed successfully"
        telegram-upload out/target/product/RMX2185/*-RMX2185.zip --caption "Build Date: $(date)" --to "$IDTL"
        msgtl -f "build.log"
    else
        msgtl -t "Build failed!"
        msgtl -f "out/error.log"
        msgtl -f "build.log"
        exit 1
    fi
}

case "$1" in  
    sync)
        res_sync;;
    build)
        build;;
    *)       
        exit 1;;
esac