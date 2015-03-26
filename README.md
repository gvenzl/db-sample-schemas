# Oracle Database Sample Schemas

Copyright (c) 2015 Oracle

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## 1. Introduction

This repository contains a copy of the Oracle Database sample schemas
that are installed with Oracle Database Enterprise Edition 12c.  These
schemas are used in Oracle documentation to show SQL language
concepts.  The schemas themselves are documented in
[Oracle Database Sample Schemas, 12c Release 1 (12.1)](http://docs.oracle.com/database/121/COMSC/toc.htm).

The schemas are:

- HR: *Human Resources*
- OE: *Order Entry*
- PM: *Product Media*
- IX: *Information Exchange*
- SH: *Sales History*
- BI: *Business Intelligence*

*Due to widespread dependence on these scripts in their current form,
no pull requests for changes can be accepted.*

## 2. Prepare Sample schemas installation

*CAUTION*: Do not use install the samples if you already have user
accounts named HR, OE, PM, IX, SH or BI.

The installation scripts are designed to run on a database host with
Oracle Database 12.1, non CDB.  Privileged database access is required
during installation.

The instructions below work on Linux and similar operating systems.
Adjust them for other platforms.

An alternative to using this repository is to download and install the
[Oracle Database 12c Release 1 Examples](http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index-092322.html)
package for your platform.

### 2.1. Clone this repository

Login as the Oracle Database software owner and clone the repository, for example

```shell
cd $HOME
git clone https://github.com/oracle/db-sample-schemas.git
```

or download and extract the ZIP file:

```shell
unzip db-sample-schemas.zip
```

The schema directory should be owned by the Oracle Database software owner.

### 2.2. Change directory

```shell
cd $HOME/db-sample-schemas
```

### 2.3. Change all embedded paths to match your working directory

The installation scripts need your current directory embedded in
various locations.  Use a text editor or the following Perl script to
make the changes, replacing occurrences of the token `__SUB__CWD__`
with your current working directory, for example
`/home/oracle/db-sample-schemas`

```shell
perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat 
```

### 2.4. Set the Oracle environment

```shell
source /usr/local/bin/oraenv
```

*Note*: Oracle's `sqlldr` utility needs to be in `$PATH` for correct
loading of the Product Media (PM) and Sales History (SH) schemas.

## 3. Installing the Samples

### 3.1. Run installation scripts

Review the [README.txt](#README.txt) for information on passwords and
pre-requirements. In particular, verify your default and temporary
tablespace names, and choose a password for each schema.

Start SQL*Plus and run the top level installation script as
discussed in [README.txt](#README.txt):

```shell
sqlplus /nolog
@mksample systempw syspw hrpw oepw pmpw ixpw shpw bipw <tablespace> <temp tablespace> </your/path/to/log/> <connection_string>
```
An example call of the script above would look like this:
```shell
sqlplus /nolog
@mksample oracle oracle hr oe pm ix sh bi EXAMPLES TEMP /home/oracle/Desktop/run/log/ @//localhost:1521/TEST
```
***Note***: Use an absolute path and also append a trailing slash to the log directory name.  
***Note***: The connection string is optional. If no connection string is specified the script will automatically connect to $ORACLE_SID

Use your current SYSTEM and SYS passwords, and also your actual
default and temporary tablespace names.  The passwords for the new
HR, OE, PM, IX, SH and BI users will be set to the values you
specify.

### 3.2. Review the installation logs

Review output in your log directory for errors.

## 4. Examples Schema pluggable database
If you did install the Examples schemas into a pluggable database
you can automatically unplug that pluggable database and plug it in
into another container database or simply replug it into the original one.

### 4.1 Unplug pluggable database
***CAUTION:*** This will unplug and drop the pluggable database from your CDB!

Start SQL*Plus and run the top level unplugging script:
```shell
sqlplus /nolog
@unplugpdb.sql syspw pdb_name conn_string_CDB
```

An example call of the scripts above would look like this:
```shell
sqlplus /nolog
@unplugpdb.sql oracle EXAMPLES @//localhost:1521/CDB
```

Once the script has completed you will have a new `examples_pdb` subfolder
which contains an archive including your PDB and its datafiles.

### 4.2 Plug Examples Schemas PDB into CDB
To replug or plug your Examples Schemas PDB into a CDB you can simply run
the top level plugging script:

Start SQL*Plus and run the top level unplugging script:
```shell
sqlplus /nolog
@plugpdb.sql syspw new_pdb_name pdb_datafiles_location conn_string_CDB
```

An example call of the scripts above would look like this:
```shell
sqlplus /nolog
@unplugpdb.sql oracle EXAMPLES /opt/oracle/oradata/CDBDEV/ @//localhost:1521/CDBDEV
```

## 5. Removing the Samples

***CAUTION***: This will drop user accounts named HR, OE, PM, IX, SH and BI.

### 5.1. Set the Oracle environment

```shell
source /usr/local/bin/oraenv
```

### 5.2. Run the schema removal script

```shell
sqlplus /nolog
@drop_sch.sql systempw conn_string logfile
```

When prompted, enter the SYSTEM password the connection string and a log file name.