ODBC SYNC
=========
Author: [Donald Merand](http://github.com/dmerand)


The Basic Idea
--------------
- External Site Scripting (ESS) is too slow. It can also be error-prone.
- Using ODBC import is faster/equally fast to download data.
    - FMP12 also has a "insert from URL" step that might be leveraged in cases where ODBC isn't an option, but an API exists.
- Using "execute SQL" is faster to upload.
    - Use timestamps to only update the stuff that's changed since the last upload.
        - You'll want to have an "external_id" field in your SQL database that corresponds to the local ID in FM. Use that to update.
    - You'll also want to make delete script-based, so you can send an SQL DELETE when a record is removed.
    - Note that when you use this technique, you may also need to update the record mod "cache" on import.
- You only need to use ESS in situations where the same data are modified on the web and in the local file.
    - You really should organize your database so that this never happens, if at all possible.


Setup
-----
To set up an ODBC sync for a data table:

1. Set up an ODBC DSN called "FM ODBC Sync" and point it to your external database. See below for details of how to set up a sample.
2. Make sure the table to sync in FileMaker has a primary key field named "id", whose values are _unique_.
3. Make sure the table to sync in FileMaker has a `_mod_ts` field which is the modification TimeStamp. The name should strictly match `_mod_ts`.
4. Add a table occurence (TO) of the table to the `ODBC Sync` file.
5. In the "Relationships" section of the "Manage Databases" dialog, link the TO from step 4 to the `SyncData` table, matching `id<=>record_id` and allowing creation and deletion in the SyncData file.
6. Create a layout using the TO from step 4 as its context. Name it the same name as the table itself. So if you called the table `people`, the TO should be named `people`, and the layout should be named `people`. Easy right?
7. Update the `SyncFields` table with a map of your local table and field names with the external table and field names. Don't leave anything blank!
8. You should now be able to run the `pub - sync ( table )` script, passing the name of your table as a parameter, and your ODBC data source should sync with your local data source!
9. _One final thing_ - in order for deletion to propagate up to ODBC, you'll need to use the `pub - delete ( table, recordID )` script. You'll have to override any native FileMaker deletion in your solutions with an API call to ODBC Sync's delete.


Sample SQL Schema
-----------------
Make a table called "people", and use the System DSN "ODBCTest" if you want to try out using this file for sync.

To do this using MySQL on OSX:

1. Set up MySQL. If you have [homebrew](http://mxcl.github.com/homebrew/) installed (do it), you can type `brew install mysql` from the terminal.
2. Open up the terminal and type `mysql -u root` to open up a MySQL session.
3. Type `CREATE DATABASE people;`
4. Type `use people;`
5. Type `CREATE TABLE people (id INTEGER AUTO_INCREMENT, external_id INTEGER, first_name VARCHAR(255), last_name VARCHAR(255), email VARCHAR(255), PRIMARY KEY(id));`
6. Open up ODBC Administrator. You may need to download it [here](http://support.apple.com/downloads/ODBC_Administrator_Tool_for_Mac_OS_X).
7. Set up a System (_not_ a User) DSN called `ODBCTest`, pointing to your MySQL database. You'll need some kind of driver like the [Open Source Driver by Actual Technologies](http://www.actualtech.com/product_opensourcedatabases.php). I'm not going to go into how to do this, but it's pretty easy.

Here's a sample of what the schema should look like:

    +-------------+--------------+------+-----+---------+----------------+
    | Field       | Type         | Null | Key | Default | Extra          |
    +-------------+--------------+------+-----+---------+----------------+
    | id          | int(11)      | NO   | PRI | NULL    | auto_increment |
    | external_id | varchar(255) | YES  |     | NULL    |                |
    | first_name  | varchar(255) | YES  |     | NULL    |                |
    | last_name   | varchar(255) | YES  |     | NULL    |                |
    | email       | varchar(255) | YES  |     | NULL    |                |
    +-------------+--------------+------+-----+---------+----------------+
