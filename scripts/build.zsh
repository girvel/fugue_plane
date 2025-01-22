#!/bin/env zsh
mkdir -p .build
rm -rf .build/*

zip -9 -r .build/fugue_plane.love lib vendor conf.lua main.lua matrix.lua normal.vert

cat "$(which love.exe)" .build/fugue_plane.love > .build/fugue_plane.exe
rm .build/fugue_plane.love

mkdir -p .build/fugue_plane
mv .build/fugue_plane.exe .build/fugue_plane/fugue_plane.exe
cp "$(dirname "$(which love.exe)")"/*.dll .build/fugue_plane/
cd .build; zip -9 -r fugue_plane_win64.zip fugue_plane; cd ..

rm -rf .build/fugue_plane
