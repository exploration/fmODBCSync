ODBC SYNC
=========
Author: Donald Merand


The Basic Idea
--------------

- External Site Scripting (ESS) is too slow. It can also be error-prone.
- Using ODBC import is faster/equally fast to download data.
    - FMP12 also has a "insert from URL" step that might be leveraged in cases where ODBC isn't an option, but an API exists.
- Using "execute SQL" is faster to upload.
    - Use the record mod count to only update the stuff that's changed since the last upload.
        - You'll want to have an "external_id" field in your SQL database that corresponds to the local ID in FM. Use that to update.
    - Use an "isnew" field to add new fields. Make the default of "isnew" true, and set it to false if the SQL INSERT works.
    - You'll also want to make delete script-based, so you can send an SQL DELETE when a record is removed.
    - Note that when you use this technique, you may also need to update the record mod "cache" on import.
- You only need to use ESS in situations where the same data are modified on the web and in the local file.
    - You really should organize your database so that this never happens, if at all possible.


Setup
-----
To set up an ODBC sync for a data table:

1. Set up an ODBC DSN called "FM ODBC Sync" and point it to your external database.
2. Make sure the table to sync has a primary key field named "id", whose values are _unique_.
3. Make sure the table to sync has a `_mod_ts` field which is the modification TimeStamp. The name should strictly match `_mod_ts`.
4. Add a table occurence (TO) of the table to the `ODBC Sync` file.
5. Link the TO to the `SyncData` table, matching `id<=>record_id` and allowing creation and deletion in the SyncData file.
6. Update the `SyncFields` table with a map of your local table and field names with the external table and field names. Don't leave anything blank!
7. You should now be able to run the `pub - sync ( table )` script, passing the name of your table as a parameter, and your ODBC data source should sync with your local data source!
8. One final thing - in order for deletion to propagate up to ODBC, you'll need to use the `pub - delete ( table, record_id )` script. You'll have to override any native FileMaker deletion in your solutions with an API call to ODBC Sync's delete.


Sample SQL Schema
-----------------
Make a table called "people", and use the System DSN "ODBCTest" if you want to try out using this file.

    +-------------+--------------+------+-----+---------+----------------+
    | Field       | Type         | Null | Key | Default | Extra          |
    +-------------+--------------+------+-----+---------+----------------+
    | id          | int(11)      | NO   | PRI | NULL    | auto_increment |
    | external_id | varchar(255) | YES  |     | NULL    |                |
    | first_name  | varchar(255) | YES  |     | NULL    |                |
    | last_name   | varchar(255) | YES  |     | NULL    |                |
    | email       | varchar(255) | YES  |     | NULL    |                |
    +-------------+--------------+------+-----+---------+----------------+
