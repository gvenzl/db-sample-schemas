Rem
Rem unplugpdb.sql
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
Rem      unplugpdb.sql - Unplugs and drops pluggable database
Rem
Rem    DESCRIPTION
Rem      This script unplugs and drops the pluggable databases including
Rem      the Example Schemas
Rem
Rem    NOTES
Rem      - CAUTION: This script will erase the following pluggable database
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem

SET HEADING OFF
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

DEFINE pdbdest    = __SUB__CWD__/examples_pdb
DEFINE pdbarchive = examples.pdb.tar
DEFINE manifest   = examplespdb.xml
DEFINE datafiles  = datafiles.list
DEFINE archive    = archive.sql
PROMPT 
PROMPT specify password for SYS as parameter 1:
DEFINE password_sys     = &1
PROMPT
Rem default pluggable database example
DEFINE pdb_name = EXAMPLES
PROMPT specify name for pluggable database as parameter 2:
DEFINE pdb_name         = &2
PROMPT 
PROMPT specify connection string as parameter 3:
DEFINE conn_string      = &3
PROMPT

HOST mkdir -p &pdbdest

CONNECT sys/&&password_sys&&conn_string as sysdba

ALTER PLUGGABLE DATABASE &pdb_name CLOSE IMMEDIATE;
ALTER PLUGGABLE DATABASE &pdb_name UNPLUG INTO '&pdbdest/&manifest';

REM Get data files location(s)
SPOOL &pdbdest/&datafiles
SELECT DISTINCT SUBSTR(d.name,1,INSTR(d.name,'/',-1)-1)
  FROM v$datafile d, v$pdbs p
    WHERE d.con_id=p.con_id AND p.name = '&pdb_name';
SPOOL OFF

REM Tar datafiles
SPOOL &archive
SELECT 'HOST tar -C ' || SUBSTR(d.name,1,INSTR(d.name,'/',-1)) || ' -rf &pdbdest/&pdbarchive ' || SUBSTR(d.name,INSTR(d.name,'/',-1)+1)
  FROM v$datafile d, v$pdbs p
    WHERE d.con_id=p.con_id AND p.name = '&pdb_name';
SPOOL OFF

@&archive
HOST rm &archive
HOST tar -C &pdbdest -rf &pdbdest/&pdbarchive &manifest
HOST tar -C &pdbdest -rf &pdbdest/&pdbarchive &datafiles
REM Delete individual files
HOST rm &pdbdest/&manifest
HOST rm &pdbdest/&datafiles
HOST gzip __SUB__CWD__/examples_pdb/&pdbarchive

DROP PLUGGABLE DATABASE &pdb_name INCLUDING DATAFILES;

EXIT
