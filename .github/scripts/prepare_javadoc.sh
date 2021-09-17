#!/bin/sh

echo "Compute the current API version..."

version=$1

if [ "$version" = "" ]
then
  version="`grep "^version" gradle.properties | cut -d= -f2 | tr -d "[:space:]"`-SNAPSHOT"
fi

echo "Computed current API version: $version"

repository_name=`git rev-parse --show-toplevel | xargs basename`
echo $repository_name

echo "Clone $repository_name..."
git clone https://github.com/calypsonet/$repository_name.git

cd $repository_name

echo "Checkout gh-pages branch..."
git checkout -f gh-pages

echo "Delete existing SNAPSHOT directory..."
rm -rf *-SNAPSHOT

echo "Create target directory $version..."
mkdir $version

echo "Copy javadoc and uml files..."
cp -rf ../build/docs/javadoc/* $version/
cp -rf ../src/main/uml/api_class_diagram.svg $version/

echo "Update versions list..."
echo "| Version | Documents |" > list_versions.md
echo "|:---:|---|" >> list_versions.md
for directory in `ls -rd */ | cut -f1 -d'/'`
do
  diagram=""
  if [ -e $directory/api_class_diagram.svg ]
  then
    diagram=" - [API class diagram]($directory/api_class_diagram.svg)"
  fi
  echo "| $directory | [API documentation]($directory)$diagram |" >> list_versions.md
done

echo "Computed all versions:"
cat list_versions.md

cd ..

echo "Local docs update finished."



