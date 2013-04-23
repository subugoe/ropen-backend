Ropen Backend - XQuery implementation of Ropen
==============================================

#Introduction
This repository contains the XQuery Sources for Ropen. 

##Login Data
URL, user name and password for the database are tored in a property file (exist.properties), Ant will refuse to work if they aren't set. The file is "protected" by .gitignore. The file format is as follows:

> exist.url=

> exist.user=

> exist.pass=

#Ant targets
##Development
You can use Ant to do some developement tasks like:

* Get the contents of the eXist database

>ant server.extract

* Import changes into an existing or new database

> ant server.deploy

* Create a EXPath package

>ant xar

##Deploymnet
You can use Ant to do some deployment tasks like:

* Create and restore a backup of the database

> ant server.backup

and
> ant server.restore

## Planed Features
* Reindex the database after manual Dataimport
* Compile the ODD Schema to RelexNG


# Installation
The XAR Package isn't tested yes, you need to deploy the application either by "ant server.deploy" or manually. The application doesn't contain data, you need to add it via "queries/upload.xq"

# Configuration
