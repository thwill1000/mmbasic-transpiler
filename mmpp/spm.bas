' Copyright (c) 2020 Thomas Hugo Williams
' For Colour Maximite 2, MMBasic 5.05

Option Explicit On
Option Default Integer

#Include "lexer.inc"

Dim search_path$

main()
End

Sub main()
  Local t$

  search_path$ = Mm.Info$(SEARCH PATH)
  Print "OPTION SEARCH PATH " + search_path$

  ' TODO: Handle search_path being empty

  lx_add_keyword("list")
  lx_add_keyword("add")
  lx_add_keyword("link")
  lx_add_keyword("clone")

  lx_parse_basic(Mm.CmdLine$)

  t$ = lx_token_lc$(0)

  If t$ = "" Then
    Error "Empty command line"
  ElseIf t$ = "list" Then
    list_files()
  ElseIf t$ = "add" Or t$ = "link" Then
    add_file()
  ElseIf t$ = "remove" Then
    remove_file()
  Else
    Error "Unknown command: " + lx_token$(0)
  EndIf
End Sub

Sub list_files()
  Local f$, i, m, n

  ' Count number of .bas files 'n' and their maximum length 'm'
  f$ = Dir$(search_path$ + "*.bas")
  Do While f$ <> ""
    n = n + 1
    If Len(f$) > m Then m = Len(f$)
    f$ = Dir$()
  Loop

 ' Create sorted list of .bas files
  Local bas_files$(n) LENGTH m
  f$ = Dir$(search_path$ + "*.bas")
  For i = 1 To n : bas_files$(i) = f$ : f$ = Dir$() : Next i
  Sort bas_files$()

  For i = 1 To n
    Print "*" + Left$(bas_files$(i), Len(bas_files$(i)) - 4)
  Next i
End Sub

Sub add_file()
  Local cmd$, target$

  If lx_num < 3 Then Error "'add' command requires two parameters"

  cmd$ = lx_token$(1)
  target$ = lx_token$(2)
 ' TODO: Handle file existing
 ' TODO: Check target exists and is absolute
' Open search_path$ + cmd$ + ".bas" For Output As #1
  Print "' Generated by Search Path Manager"
  Print "Run " + Chr$(34) + target$ + Chr$(34) + ", Mm.CmdLine$
  Print "End"
'  Close #1
End Sub

Sub remove_file()
End Sub
