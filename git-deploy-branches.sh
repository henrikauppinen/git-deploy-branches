#!/bin/bash
# Script for deploying all repository branches
# Author: Henri Kauppinen

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# read config
. conf.cfg

indexfile=$deployment_dir/index.html

init_local_repository(){
    if [ ! -d $local_repository_dir ]; then
        mkdir -p $local_repository_dir
    fi

    (cd $local_repository_dir; git clone $remote_repository .)
}

link_files(){
    echo "Copying additional files to $deployment_dir/$1"
    cp -R $basedir/app_files/* $deployment_dir/$1/
}

deploy_branch() {
    echo "Deploying $1"

    if [ ! -d $deployment_dir ]; then
        mkdir -p $deployment_dir
    fi

    if [ ! -d $deployment_dir/$1 ]; then
        mkdir -p $deployment_dir/$1
    fi

    rsync -ap --stats --exclude ".git" --delete --delete-excluded $local_repository_dir/ $deployment_dir/$1

    # git log -p -1 > $deployment_dir/$1/gitlog.txt

}

make_indexfile_row(){
    echo "<div class='branchrow'><a href='$1/'>$1</a> - <a href='https://github.com/$repository_reference/compare/$1'>Compare on Github.com</a><br />" >> $indexfile
    echo "<div class='lastcommit'><pre>" >> $indexfile
    git log -1 >> $indexfile
    echo "</pre></div></div><hr/>" >> $indexfile
}

# main
if [ ! -d $local_repository_dir/.git ]; then
    init_local_repository
fi

# reset index.html

echo "<html><head><title>git-deploy-branches</title></head><body>" > $indexfile

cd $local_repository_dir

git remote prune origin
git fetch --all

for branch in `git branch -r | grep -v HEAD | sed -e 's/origin\///'`; do

    git checkout $branch
    git pull

    deploy_branch $branch
    link_files $branch
    make_indexfile_row $branch
done

echo "</body></html>" >> $indexfile
