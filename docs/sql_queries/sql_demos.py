# import the database with sqlmodel or sqlalchemy

import sqlite3

path = "/Users/ouafikouera/Documents/:Volumes:DBeaver Community:Volumes:DBeaver Community:DBeaver.app"
with sqlite3.connect(path) as cn:
    cursor = cn.cursor()
    cursor.execute("SELECT * FROM complaint")
    results = cursor.fetchall()
    print(results)
    cursor.close()
   