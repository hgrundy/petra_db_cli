::lc_petra_db.exe 4 Administrator EDBDefault win_seven 12010 "TEAPOT" "c:\temp\out.csv" "select * from well"
::./lib/lc_petra_db.exe 4 Administrator EDBDefault win_seven 12010 "ENERDEQ_TEST" "NO_CSV" "select * from well"

::./lib/lc_petra_db.exe 3 "c:\geoplus1\Projects\Tutorial\DB" "c:\temp\out.csv" "select uwi,wsn,leasename from well"
::./lib/lc_petra_db.exe 3 "c:\geoplus1\Projects\TEAPOT\DB" "NO_CSV" "select uwi,wsn,leasename from well"
lc_petra_db.exe 4 Administrator EDBDefault win_seven 12010 "TEAPOT" "NO_CSV" "select data from metadata"