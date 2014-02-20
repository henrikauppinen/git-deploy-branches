#!/bin/sh

conffilename=./conf.cfg

if [ -e $conffilename ]; then
	. $conffilename
	link_config=$rootdir/shared/links.cfg
fi

pruning() {
	cd $rootdir
        (cd master;git remote prune origin) | sed -e '/Pruning origin/,+d' -e '/URL\:/,+d' -e 's/ \* \[pruned\] origin\///' | while read branchname ;
        do
		# @todo safe mode, just move the branch folders to deleted directory for now
          	if [ -d $branchname ];then
                        mv $branchname deleted/$branchname
                fi
        done
}

create_links(){
	if [ -e $link_config ]; then
		cat $rootdir/shared/links.cfg | while read link ;
		do
			IFS=' ' read -a paths <<< "${link}"
			# @todo check paths
			ln -s $rootdir/shared/${paths[0]} $rootdir/$1/${paths[1]}
		done
	fi
}

update(){
	cd $rootdir
        (cd master; git pull -q;git branch -r) | sed -e '/master/,+d' -e 's/origin\///' | while read branchname ;
        do
          	if [ -d $branchname ]; then
                        (cd $branchname;git pull)
                else
                    	git clone $remote -b $branchname --depth 1 $branchname
			create_links $branchname
                fi
        done
}

installation(){
	echo "Enter full repository url (example: git@github.com:username/repository.git):"
        read -r remote

        echo "Enter directory where you want to deploy (ie: /var/www/html/site_test/:)"
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
if [[ $# -eq 0 ]]; then
	echo "Usage: git-deploy-branches.sh [install|update]"
	echo ""
	echo "Arguments:"
	echo "   install: Initial installation. Configuration file is created in the same directory where the script is launched."
	echo ""
	echo "   update: Run update (prune removed branches, update existing and create new branches)"
	echo ""
fi

if [ "$1" == "install" ]; then
	installation
fi

if [ "$1" == "update" ]; then
	update
fi
