git-deploy-branches
===================

Tool for deploying all branches in the repository (for example to application test environment).

Configuration
=============

Configuration file conf.cfg must include these lines:

    remote=(url to git repository)
    rootdir=(path to wwwroot)

Additional files can be linked to application wwwroot by using link configuration file in shared/links.cfg:

    testfile.php testfile.php
    db.php configuration/db.php
    [sourcefile] [target]

Files are placed in shared/ -folder and links.cfg file will link these files to application directory.
