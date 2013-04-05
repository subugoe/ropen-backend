Ropen Backend - XQuery implementation of Ropen
==============================================

#Introduction
This repository contains the XQuery Sources for Ropen. 

##Login Data
URL, user name and password for the database are tored in a property file (exist.properties), Ant will refuse to work if they aren't set. The file is "protected" by .gitignore. The file format is as follows:

> exist.url=

> exist.user=

> exist.pass=

#Development
You can use Ant to do some developement tasks like:

* Get the contents of the eXist database
* Import changes into an existing or new database
* Create a EXPAth package

#Deploymnet
You can use Ant to do some deployment tasks like:

* Create and restore a backup of the database
* Import changes into an existing or new database
* Reindex the database after manual Dataimport
