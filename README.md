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
