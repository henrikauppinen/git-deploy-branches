#!/bin/sh
# Script for deploying all repository branches
# Author: Henri Kauppinen

conffilename=./conf.cfg

if [ -e $conffilename ]; then
	. $conffilename
	link_config=$rootdir/shared/links.cfg
fi

pruning() {
	cd $rootdir

	if [ ! -d $rootdir/deleted ]; then
		mkdir $rootdir/deleted
	fi

        (cd master;git remote prune origin) | sed -e '/Pruning origin/,+d' -e '/URL\:/,+d' -e 's/ \* \[pruned\] origin\///' | while read branchname ;
        do
		# @todo safe mode, just move the branch folders to deleted directory for now
          	if [ -d $branchname ];then
			echo "Pruning $branchname"
                        mv $branchname deleted/$branchname
                fi
        done
}

create_links(){
	if [ -e $link_config ]; then
		cat $rootdir/shared/links.cfg | while read link ;
		do
			echo "Creating links for $1"
			IFS=' ' read -a paths <<< "${link}"
			if [ ! -L $rootdir/$1/${paths[1]} ]; then
				ln -s $rootdir/shared/${paths[0]} $rootdir/$1/${paths[1]}
			fi
		done
	fi
}

update(){
	cd $rootdir

        (cd master; git pull -q;git branch -r) | sed -e '/master/,+d' -e 's/origin\///' | while read branchname ;
        do
          	if [ -d $branchname ]; then
			echo "Checking updates for $branchname"
                        (cd $branchname;git pull -q)
                else
			echo "Creating $branchname"
                    	git clone $remote -b $branchname --depth 1 $branchname
                fi

		create_links $branchname

        done

	# check links for master as well
	create_links master
}

installation(){

	if [ ! $remote == "" ]; then
		remote_sug=$remote
	else
		remote_sug="git@github.com:username/repository.git"
	fi
	if [ ! $rootdir == "" ]; then
		rootdir_sug=$rootdir
	else
		rootdir_sug="/var/www/html/repository"
	fi

	echo "Enter full repository url (example: $remote_sug):"
        read -r remote -e -i

        echo "Enter directory where you want to deploy (ie: $rootdir_sug)"
        read -r rootdir

        # create install directory
	# @todo instead of checking for directory existence, check if contains files or directories
        if [ ! -d $rootdir ]; then
		echo "Creating configuration..."
	        mkdir $rootdir
		mkdir $rootdir/shared
		touch $rootdir/shared/links.cfg
		echo "remote=$remote" >> $conffilename
		echo "rootdir=$rootdir" >> $conffilename

		# init repositories
		echo "Cloning master..."
		(cd $rootdir;git clone $remote -b master --depth 1 master)
		echo "Cloning branches..."
		update
		echo "Installation complete!"
        else
		echo "Directory $rootdir exists! Not doing anything just to be safe."
	fi
}

# main
if [ "$1" == "install" ]; then
	installation
elif [ "$1" == "update" ]; then
	update
	pruning
elif [ "$1" == "fetch" ]; then
	update
elif [ "$1" == "prune" ]; then
	pruning
else
	echo "Usage: git-deploy-branches.sh [install|update]"
        echo ""
        echo "Arguments:"
        echo "   install: Initial installation. Configuration file is created in the same directory where the script is launched."
        echo ""
        echo "   update: Run update (prune removed branches, update existing and create new branches)"
        echo ""
fi
