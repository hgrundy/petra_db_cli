;----------
; lc_petra_db.exe  --  version 0.0.2  --  LogicalCat LLC (c) 2013 
;
; A command line utility to query PETRA databases via a SQL query and write
; the resultset to a csv file. The CSV column headers will match SQL fields.
; Both PETRA v3, DBISAM and v4 ElevateDB are supported. 
;
; The utility will check the registry for drivers and install them if necessary. 
;
; CHANGE LOG:
;
; 0.0.1 initial commit
; 0.0.2 fixed formatting and typos. 
;       removed un-needed <Array> dependency
;       commented out cleanup() method. (it doesn't quite work--leaves .dlls)
;
; COMPILE AS CONSOLE APP:

; C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2Exe.exe /in lc_petra_db.au3 /out lc_petra_db.exe /console
;
; Note: adding RequireAdmin will allow this script to create the required registry entries, but will also force it to run as a separate console. Boo!

;#RequireAdmin
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
$catchError = ObjEvent("AutoIt.Error","WriteError") ; Initialize a COM error handler

If $CmdLine[0] == 0 Then help()
If $CmdLine[1] == "/?" Then help()
If $CmdLine[1] == "?" Then help()
If $CmdLine[1] == "help" Then help()
If $CmdLine[1] == "eula" Then eula()


Global $version = $CmdLine[1] ; petra version 3 or 4

; TODO maybe switch the base to c:\logicalcat or something later?
Global $dll_base = EnvGet("temp")

validate()

query()

;cleanup()


;----------
;
Func validate()
  If (Number($version) < 3) or (Number($version) > 4) Then
    ConsoleWrite($version & " is not a valid version number")
    Exit
  ElseIf (Number($version) == 3) Then
    If ($CmdLine[0] < 4) Then
      ConsoleWrite("Wrong number of args..." & @CRLF)
      help()
    EndIf
    Global $db  = $CmdLine[2]
    Global $csv = $CmdLine[3]
    Global $sql = $CmdLine[4]
    check_v3_driver()
  ElseIf (Number($version) == 4) Then
    If ($CmdLine[0] < 8) Then
      ConsoleWrite("Wrong number of args..." & @CRLF)
      help()
    EndIf
    Global $usr = $CmdLine[2]
    Global $pwd = $CmdLine[3]
    Global $srv = $CmdLine[4]
    Global $prt = $CmdLine[5]
    Global $db  = $CmdLine[6]
    Global $csv = $CmdLine[7]
    Global $sql = $CmdLine[8]
    check_v4_driver()
  EndIf

  If (StringLen($db) < 2) or (StringLen($csv) < 2) or (StringLen($sql) < 2) Then
    ConsoleWrite("Check your args--some are too short to be valid")
    Exit
  EndIf
EndFunc


;----------
;
Func check_v3_driver()
  Local $reg3 = RegRead("HKLM64\SOFTWARE\Wow6432Node\ODBC\ODBCINST.INI\lc_petra_3_odbc","Driver")
  If (StringLen($reg3) == 0) Then
    ConsoleWrite("Adding PETRA 3 DBISAM drivers..." & @CRLF)
    Local $dll_path = $dll_base & "\dbisamod.dll"
    FileInstall ( "./dbisamod.dll", $dll_path , 1 )
    Local $key3 = "HKLM64\SOFTWARE\Wow6432Node\ODBC\ODBCINST.INI\lc_petra_3_odbc"

    RegWrite($key3, "APILevel", "REG_SZ", "1")
    RegWrite($key3, "ConnectFunctions", "REG_SZ", "YYY")
    RegWrite($key3, "Driver", "REG_SZ", $dll_path)
    RegWrite($key3, "DriverODBCVer", "REG_SZ", "03.00")
    RegWrite($key3, "FileExtns", "REG_SZ", "*.dat,*.idx,*.blb")
    RegWrite($key3, "FileUsage", "REG_SZ", "1")
    RegWrite($key3, "Setup", "REG_SZ", $dll_path)
    RegWrite($key3, "SQLLevel", "REG_SZ", "0")
    RegWrite($key3, "UsageCount", "REG_DWORD", "1")
  EndIf
EndFunc


;----------
;
Func check_v4_driver()
  Local $reg4 = RegRead("HKLM64\SOFTWARE\Wow6432Node\ODBC\ODBCINST.INI\lc_petra_4_odbc","Driver")
  If (StringLen($reg4) == 0) Then
    ConsoleWrite("Adding PETRA 4 ElevateDB drivers..." & @CRLF)
    Local $dll_path = $dll_base & "\edbodbc.dll"
    FileInstall ( "./edbodbc.dll", $dll_path , 1 )
    Local $key4 = "HKLM64\SOFTWARE\Wow6432Node\ODBC\ODBCINST.INI\lc_petra_4_odbc"

    RegWrite($key4, "APILevel", "REG_SZ", "1")
    RegWrite($key4, "ConnectFunctions", "REG_SZ", "YYY")
    RegWrite($key4, "Driver", "REG_SZ", $dll_path)
    RegWrite($key4, "DriverODBCVer", "REG_SZ", "03.00")
    RegWrite($key4, "FileExtns", "REG_SZ", "*.EDBTbl,*.EDBIdx,*.EDBBlb")
    RegWrite($key4, "FileUsage", "REG_SZ", "1")
    RegWrite($key4, "Setup", "REG_SZ", $dll_path)
    RegWrite($key4, "SQLLevel", "REG_SZ", "0")
    RegWrite($key4, "UsageCount", "REG_DWORD", "1")
  EndIf
EndFunc


;----------
; 
Func query()
  Local $out = true;
  If ($csv == "NO_CSV") Then
    $out = false
  EndIf


  $conn = ObjCreate("ADODB.Connection")
  
  ; build the dsn based on version requirements
  If (Number($version) == 3) Then

    $dsn = "DRIVER=lc_petra_3_odbc;CATALOGNAME=" & $db &";"

  ElseIf (Number($version) == 4) Then

    $dsn = "DRIVER={lc_petra_4_odbc};UID=" & $usr &";PWD=" & $pwd & ";ADDRESS=" & $srv & ";HOST=" & $srv & ";TYPE=REMOTE;DATABASE=" & $db & ";PORT=" & $prt & ";READONLY=TRUE;KEEPTABLESOPEN=FALSE;ROWLOCKPROTOCOL=PESSIMISTIC;TIMEOUT=900;"

  EndIf    
  
  $conn.Open($dsn)

  $rs = ObjCreate("ADODB.Recordset")
  $count = 0

  $rs.Open($sql, $conn)

  If $rs.Fields.Count > 0 Then
    If ($out) Then
      FileOpen($csv,2)
    EndIf

    $header = ""
    $iField = 0

    ; create header record with field names
    For $Field In $rs.Fields
      $header = $header & csvify($Field.name)
      $iField += 1
      If ($rs.Fields.Count > $iField) Then
        $header = $header & ","
      EndIF
    Next

    If ($out) Then
      FileWriteLine($csv, $header) 
    EndIf
    ;TODO maybe print dot via modulo?
    ConsoleWrite(".")
    ;ConsoleWrite("WRITE THIS --> " & $header & @CRLF)

    ; create additional rows
    $iRow = 1
    While Not $rs.EOF
      $arow = ""
      $iField = 0
      For $Field In $rs.Fields
        $sValue = $rs.Fields($Field.name).value
        $arow = $arow & csvify($sValue)
        $iField += 1
        If ($rs.Fields.Count > $iField) Then
          $arow = $arow & ","
        EndIf
      Next

      If ($out) Then
        FileWriteLine($csv, $arow) 
        ConsoleWrite(".")
      Else
        ConsoleWrite($arow & "|")
      EndIf

      $rs.MoveNext
      $iRow += 1
      $count += 1
    WEnd
    If ($out) Then
      FileClose($csv)
    EndIf
  EndIf
 
  $rs.Close
  $conn.Close
  
  If ($out) Then
    If (FileExists($csv)) Then
      ConsoleWrite(@CRLF & @CRLF & "Wrote "& $count &" CSV records: " & $csv & @CRLF & @CRLF)
    EndIf
  EndIf
EndFunc


;----------
;
Func csvify($s)
  $s = StringStripCR($s)                      ;strip carriage return
  ;$s = StringRegExpReplace($s, """", """""")  ;quote quotes
  $s = StringRegExpReplace($s, """", "\\""")  ;escape internal quotes
  $s = StringReplace($s, "|", ".")            ;replace pipes (used as delimiter)
  $s = StringStripWS($s, 3)                   ;strip left and right whitespace
  $s = """" & $s & """"                       ;enclose it in double quotes
  return $s
EndFunc


;----------
;
Func help()
  $msg = "Query PETRA project databases using SQL and dump results to CSV file." & @CRLF & _
  @CRLF & "Syntax:" & @CRLF & _
  @CRLF & "lc_petra_db.exe <version> <db> [usr] [pwd] [srv] [prt] <csv> <sql>" & @CRLF & _
  @CRLF & "         version -- 3 or 4" & _ 
  @CRLF & "   [v4 only] usr -- ElevateDB Server username" & _
  @CRLF & "   [v4 only] pwd -- ElevateDB Server password" & _
  @CRLF & "   [v4 only] srv -- ElevateDB Server hostname or IP" & _
  @CRLF & "   [v4 only] prt -- ElevateDB Server port (12010 default)" & _
  @CRLF & "              db -- for 3 use full path to DB folder; for 4 use database name" & _
  @CRLF & "             csv -- path to output CSV file" & _
  @CRLF & "             sql -- an ElevateDB or DBISAM SQL query string" & @CRLF & _
  @CRLF & "[lc_petra_db.exe /? or ? for help. lc_petra_db.exe eula for legal.]" & @CRLF & _
  @CRLF & "[ Want stdout only? set csv = 'NO_CSV' and no file will be written ]" & @CRLF & _
  @CRLF & @CRLF & "Examples:" & @CRLF & _
  @CRLF & "lc_petra_db.exe 4 Administrator EDBDefault 192.168.1.12 12010 ""TEAPOT"" ""c:\temp\out.csv"" ""select * from well""" & @CRLF & _
  @CRLF & "lc_petra_db.exe 3 ""c:\Projects\TUTORIAL\DB"" ""c:\temp\out.csv"" ""select * from well""" & @CRLF
  ConsoleWrite($msg)
  Exit
EndFunc


;----------
;
Func eula()
  Local $s = @CRLF & _
  @CRLF & " ---------------------------------------------------------------------- " & _
  @CRLF & "| Copyright (c) 2013    |   LogicalCat LLC   |     www.logicalcat.com  |" & _
  @CRLF & "|======================================================================|" & _
  @CRLF & "|This utility is free and unsupported. Access to PETRA and ElevateSoft |" & _
  @CRLF & "|products are covered by your Software License Agreement with IHS Inc. |" & _
  @CRLF & "|All queries are read-only. Attempts to update/insert data will fail.  |" & _
  @CRLF & "|======================================================================|" & _
  @CRLF & "|THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,       |" & _
  @CRLF & "|EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    |" & _
  @CRLF & "|MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.|" & _
  @CRLF & "|IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR     |" & _
  @CRLF & "|OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, |" & _
  @CRLF & "|ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR |" & _
  @CRLF & "|OTHER DEALINGS IN THE SOFTWARE.                                       |" & _
  @CRLF & " ---------------------------------------------------------------------- "
  ConsoleWrite($s)
  Exit
EndFunc


;----------
;
Func cleanup()
  RegDelete("HKLM64\SOFTWARE\Wow6432Node\ODBC\ODBCINST.INI\lc_petra_3_odbc")
  RegDelete("HKLM64\SOFTWARE\Wow6432Node\ODBC\ODBCINST.INI\lc_petra_4_odbc")
  FileDelete($dll_base & "\dbisamod.dll")
  FileDelete($dll_base & "\edbodbc.dll")
EndFunc


;----------
;
Func WriteError()
  Local $e = "==================================================" & @CRLF & _
    $catchError.description  & @CRLF & _
    $catchError.windescription & @CRLF & _
    "err.scriptline is: " & $catchError.scriptline   & @CRLF & _
    $catchError.source & _
    @CRLF &  "==================================================" & @CRLF
  ConsoleWrite($e)
  Exit
Endfunc

