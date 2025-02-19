#!/usr/bin/env bash

set -e  # Fail on any command error

if ! command -v wine &> /dev/null; then
  echo "Missing command: wine"
  exit 1
fi

SRC_DIR=./dist/trilium-windows-x64-src

if [ "$1" != "DONTCOPY" ]
then
    ./bin/copy-trilium.sh $SRC_DIR
fi

echo "Copying required windows binaries"

cp -r bin/better-sqlite3/win-better_sqlite3.node $SRC_DIR/node_modules/better-sqlite3/build/Release/better_sqlite3.node

echo "Packaging windows x64 electron build"

./node_modules/.bin/electron-packager $SRC_DIR --asar --out=dist --executable-name=trilium --platform=win32  --arch=x64 --overwrite --icon=images/app-icons/win/icon.ico

BUILD_DIR=./dist/trilium-windows-x64
rm -rf $BUILD_DIR

mv "./dist/TriliumNext Notes-win32-x64" $BUILD_DIR

cp bin/tpl/anonymize-database.sql $BUILD_DIR/

cp -r dump-db $BUILD_DIR/
rm -rf $BUILD_DIR/dump-db/node_modules

cp bin/tpl/trilium-{portable,no-cert-check,safe-mode}.bat $BUILD_DIR/

if [ "$1" != "DONTPACK" ]
then
  echo "Zipping windows x64 electron distribution..."
  VERSION=`jq -r ".version" package.json`

  cd dist
  zip -r9 trilium-windows-x64-${VERSION}.zip trilium-windows-x64
fi