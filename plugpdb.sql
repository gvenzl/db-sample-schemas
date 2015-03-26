Rem
Rem plugpdb.sql
Rem
Rem Copyright (c) 2001, 2015, Oracle and/or its affiliates.  All rights reserved. 
Rem 
Rem Permission is hereby granted, free of charge, to any person obtaining
Rem a copy of this software and associated documentation files (the
Rem "Software"), to deal in the Software without restriction, including
Rem without limitation the rights to use, copy, modify, merge, publish,
Rem distribute, sublicense, and/or sell copies of the Software, and to
Rem permit persons to whom the Software is furnished to do so, subject to
Rem the following conditions:
Rem 
Rem The above copyright notice and this permission notice shall be
Rem included in all copies or substantial portions of the Software.
Rem 
Rem THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
Rem EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
Rem MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
Rem NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
Rem LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
Rem OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
Rem WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
Rem
Rem    NAME
Rem      plugpdb.sql - Plugs pluggable database EXAMPLES into CDB
Rem
Rem    DESCRIPTION
Rem      This script plugs the pluggable databases EXAMPLES into
Rem      and existing container database. The EXMAPLES pluggable
Rem      database contains all Oracle12c Sample Schemas.
Rem
Rem    NOTES
Rem      - CAUTION: This script will erase the following pluggable database:
Rem        - EXAMPLES
Rem      - USAGE: To return the Sample Schemas to their initial 
Rem        state, you can call this script and pass the passwords
Rem        for SYS, SYSTEM and the schemas as parameters.
Rem        Example: @/your/path/to/mksample mgr secure h1 o2 p3 q4 s5
Rem        (please choose your own passwords for security purposes)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem

SET FEEDBACK OFF
SET NUMWIDTH 10
SET LINESIZE 1000
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 999
SET ECHO OFF
SET CONCAT '.'
SET VERIFY OFF;
SET SHOWMODE OFF

DEFINE pdborig    = __SUB__CWD__/examples_pdb
DEFINE pdbdest    = &pdborig/EXAMPLES
DEFINE pdbarchive = examples.pdb.tar
DEFINE manifest   = examplespdb.xml
DEFINE datafiles  = datafiles.list
DEFINE plugscript = &pdbdest/plug.sql

PROMPT 
PROMPT specify password for SYS as parameter 1:
DEFINE password_sys        = &1
PROMPT 
DEFINE pdb_name = EXAMPLES
PROMPT specify name for pluggable database as parameter 2:
DEFINE pdb_name            = &2
PROMPT 
DEFINE pdb_location = /opt/oracle/oradata
PROMPT specify pdb datafile location as parameter 3:
DEFINE pdb_location        = &3
PROMPT
PROMPT specify connection string as parameter 4:
DEFINE conn_string         = &4
PROMPT

CONNECT sys/&&password_sys&&conn_string as sysdba

HOST mkdir -p &pdbdest
HOST gunzip -c &pdborig/&pdbarchive* > &pdborig/&pdbarchive
HOST tar -xf &pdborig/&pdbarchive -C &pdbdest

REM Create folder structure for Pluggable Database
HOST mkdir -p &pdb_location/&pdb_name

REM Create plug script including the CREATE PLUGGABLE DATABASE command
HOST echo "CREATE PLUGGABLE DATABASE &pdb_name USING '&pdbdest/&manifest' SOURCE_FILE_NAME_CONVERT=(" > &plugscript

REM For every location in datafiles.list create an entry for SOURCE_FILE_NAME_CONVERT
HOST origs=($(cat &pdbdest/&datafiles)); for entry in ${origs[@]}; do echo "'$entry','&pdbdest'," >> &plugscript; done;

REM Remove last comma from file
HOST sed -i '$s/,$//' &plugscript

REM Finish CREATE PLUGGABLE DATABASE command with FILE_NAME_CONVERT statement
HOST echo ") MOVE FILE_NAME_CONVERT=('&pdbdest','&pdb_location/&pdb_name');" >> &plugscript

@&plugscript

ALTER PLUGGABLE DATABASE &pdb_name OPEN;

HOST rm __SUB__CWD__/examples_pdb/&pdbarchive
HOST rm -r &pdbdest

EXIT
