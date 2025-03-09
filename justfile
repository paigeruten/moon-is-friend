build:
    mkdir -p build
    pdc src build/MoonIsFriend.pdx

run: build
    open build/MoonIsFriend.pdx
