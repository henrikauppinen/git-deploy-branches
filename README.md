git-deploy-branches
===================

Tool for deploying all branches in the repository (for example to application test environment).

Configuration
=============

Configuration file conf.cfg must include these lines:

    remote_repository=git@github.com:account/repository.git
    repository_reference=account/repository
    local_repository_dir=/tmp/templocalrepositorydir
    deployment_dir=/var/www/html/wwwroot/deploymentdirectory

Additional files can be copied to application wwwroot by placing the files in app_files/ -directory (ie. configuration files). Use same file and directory structure as in your application so that the files go to correct directories.

Usage
=====

Tool will clone the remote_repository and checkout every branch and copy the files to deployment directory, example:

    company/repository.git
    master
    featurebranch1
    featurebranch2

Resulting deployment directory structure:

	/var/www/html/wwwroot/deploymentdirectory/master/
	/var/www/html/wwwroot/deploymentdirectory/featurebranch1/
	/var/www/html/wwwroot/deploymentdirectory/featurebranch2/

Script will create a index.html -page into deployment_dir which includes links to branches, latest commit message from each branch and also link to github compare-page.
