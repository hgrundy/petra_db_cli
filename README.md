petra_db_cli
---------

IHS [PETRA] is among the most commonly used interpretation software packages for energy exploration. At the core of each PETRA project lives a not-exactly-mainstream database from the vendor [Elevate Software]. The earlier (and vastly more popular) v3 database uses Elevate's [DBISAM] while v4 uses the more robust [ElevateDB].

Even a modest PETRA environment can host dozens projects containing millions of well and production records. This has traditionally been a source of worry for data managers and/or IT workers.

This tiny [petra_db_cli] (PETRA database command line interface) utility hopes to minimize this data management problem. It provides a brutally simple means to run **READ-ONLY** queries against any PETRA database. It can write results to stdout or to a CSV file for later use. The utility supports the user/password/port schemes provided by v4 in a totally insecure way, so use with caution if you are among that subset of users.

> I haven't actively used this in a while, but PETRA hasn't changed much either. It should still work. Contact me if you are interested in using this in an actual data management project and would like assistance.

This utility cannot perform writes, so it should be 100% safe. If you need to write to PETRA v3...let's talk.

---
**This is an [AutoIT] script. You must compile the .au3 file first to generate petra_db_cli.exe.  TO COMPILE AS CONSOLE APP (assuming you have AutoIT3 installed):**

    C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2Exe.exe /in lc_petra_db.au3 /out lc_petra_db.exe /console

---
#### Examples: (run petra_db_cli.exe /? for help)  

Use v4 with default login to query the TEAPOT project, output to screen: 

    lc_petra_db.exe 4 Administrator EDBDefault win_seven 12010 "TEAPOT" "NO_CSV" "select data from metadata"

Same as above, but write to CSV file:

    lc_petra_db.exe 4 Administrator EDBDefault win_seven 12010 "TEAPOT" "c:\temp\out.csv" "select * from well"

Enclose project names with spaces in double quotes:

    lc_petra_db.exe 4 Administrator EDBDefault win_seven 12010 "ENERDEQ_TEST" "NO_CSV" "select * from well"


Use v3 and output to CSV (v4 credentials are not required):

    lc_petra_db.exe 3 "c:\geoplus1\Projects\Tutorial\DB" "c:\temp\out.csv" "select uwi,wsn,leasename from well"

Query v3 TEAPOT project and write to screen:

    lc_petra_db.exe 3 "c:\geoplus1\Projects\TEAPOT\DB" "NO_CSV" "select uwi,wsn,leasename from well"





[petra_db_cli]:https://github.com/rbhughes/petra_db_cli
[Elevate Software]:http://www.elevatesoftware.com/
[dbisam]:http://www.elevatesoft.com/products?category=dbisam
[elevatedb]:http://www.elevatesoft.com/products?category=edb
[PETRA]:https://www.ihs.com/Info/en/a/intelligent-workflows/petra.html
[AutoIT]:https://www.autoitscript.com/site/autoit/



