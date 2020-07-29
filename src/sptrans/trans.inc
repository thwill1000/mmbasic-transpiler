' Copyright (c) 2020 Thomas Hugo Williams

Const MAX_NUM_IFS = 10

' We ignore the 0'th element in these.
Dim num_comments(MAX_NUM_FILES)
Dim num_ifs(MAX_NUM_FILES)
Dim if_stack(MAX_NUM_FILES, MAX_NUM_IFS)

' The set of active flags.
Const MAX_NUM_FLAGS = 10
Dim flags$(MAX_NUM_FLAGS - 1)
Dim flags_sz = 0
set_init(flags$(), MAX_NUM_FLAGS)

' The map of replacements.
Const MAX_NUM_REPLACEMENTS = 200
Dim replace$(MAX_NUM_REPLACEMENTS - 1) Length 50
Dim with$(MAX_NUM_REPLACEMENTS - 1) Length 50
Dim replace_sz
map_init(replace$(), with$(), MAX_NUM_REPLACEMENTS)

Sub transpile(s$)
  lx_parse_basic(s$)
  If err$ <> "" Then cerror(err$)

  If lx_token_lc$(0) = "'!endif" Then process_endif()

  add_comments()
  apply_replacements()
  If err$ <> "" Then cerror(err$)

  If lx_token_lc$(0) = "#include" Then process_include()

  If lx_type(0) <> TK_DIRECTIVE Then Exit Sub

  Local t$ = lx_directive$(0)
  If     t$ = "!clear"        Then : process_clear()
  ElseIf t$ = "!comments"     Then : process_comments()
  ElseIf t$ = "!comment_if"   Then : process_if()
  ElseIf t$ = "!empty-lines"  Then : process_empty_lines()
  ElseIf t$ = "!indent"       Then : process_indent()
  ElseIf t$ = "!uncomment_if" Then : process_if()
  ElseIf t$ = "!replace"      Then : process_replace()
  ElseIf t$ = "!set"          Then : process_set()
  ElseIf t$ = "!spacing"      Then : process_spacing()
  Else : cerror("Unknown directive: " + Mid$(t$, 2))
  EndIf

  lx_parse_basic("' PROCESSED: " + Mid$(lx_line$, lx_start(0) + 1))
End Sub

Sub process_endif()
  update_num_comments(- pop_if())
  lx_parse_basic("' PROCESSED: " + Mid$(lx_line$, lx_start(0) + 1))
End Sub

Sub update_num_comments(x)
  num_comments(num_files) = num_comments(num_files) + x
End Sub

Function pop_if()
  If num_ifs(num_files) = 0 Then Error "If directive stack is empty"
  pop_if = if_stack(num_files, num_ifs(num_files))
  num_ifs(num_files) = num_ifs(num_files) - 1
End Function

Sub add_comments()
  Local nc = num_comments(num_files)
  If nc > 0 Then
    lx_parse_basic(String$(nc, "'") + " " + lx_line$)
  ElseIf nc < 0 Then
    Do While nc < 0 And lx_num > 0 And lx_type(0) = TK_COMMENT
      lx_parse_basic(Space$(lx_start(0)) + Right$(lx_line$, Len(lx_line$) - lx_start(0)))
      nc = nc + 1
    Loop
  EndIf
End Sub

' Applies replacements to the currently parsed line, lx_line$.
Sub apply_replacements()
  If replace_sz = 0 Then Exit Sub

  Local i, r$, s$
  For i = 0 TO lx_num - 1
    r$ = map_get$(replace$(), with$(), replace_sz, lx_token_lc$(i))
    If r$ <> Chr$(0) Then
      s$ = Left$(lx_line$, lx_start(i) - 1) + r$ + Mid$(lx_line$, lx_start(i) + lx_len(i))
      lx_parse_basic(s$)
      ' TODO: at the moment this can't change the number of tokens, but when it
      '       can this will need looking at closer.
    EndIf
  Next i
End Sub

Sub process_clear()
  Local t$ = lx_token_lc$(1)
  If lx_num <> 2 Or t$ = "" Then
    cerror("Syntax error: !clear directive expects a <flag> argument")
  EndIf
  If set_get(flags$(), flags_sz, t$) < 0 Then
    ' TODO: Is this really the behaviour we want?
    cerror("Error: flag '" + t$ + "' is not set")
  EndIf
  set_remove(flags$(), flags_sz, t$)
End Sub

Sub process_comments()
  If lx_num > 2 Then cerror("Syntax error: !comments directive has too many arguments")
  op_set_comments(lx_token_lc$(1))
  If err$ <> "" Then cerror("Syntax error: !comments directive " + err$)
End Sub

Sub process_if()
  Local invert, is_set, t$

  t$ = lx_token_lc$(1)

  If lx_num = 2 Then
    ' Do nothing
  ElseIf lx_num = 3 Then
    If t$ = "not" Then
      invert = 1
    Else
      t$ = "Syntax error: " + lx_directive$(0) + " directive followed by unexpected token {"
      t$ = t$ + lx_token$(1) + "}"
      cerror(t$)
    EndIf
  Else
    cerror("Syntax error: " + lx_directive$(0) + " directive with invalid arguments")
  EndIf

  Local x = set_get(flags$(), flags_sz, t$) > -1
  If invert Then x = Not is_set

  If lx_directive$(0) = "!comment_if" Then
    push_if(x)
    If x Then update_num_comments(+1)
  ElseIf lx_directive$(0) = "!uncomment_if" Then
    push_if(-x)
    If x Then update_num_comments(-1)
  Else
    Error
  EndIf
End Sub

Sub push_if(x)
  If num_ifs(num_files) = MAX_NUM_IFS Then Error "Too many if directives"
  num_ifs(num_files) = num_ifs(num_files) + 1
  if_stack(num_files, num_ifs(num_files)) = x
End Sub

Sub process_empty_lines()
  If lx_num > 2 Then cerror("Syntax error: !empty-lines directive has too many arguments")
  op_set_empty_lines(lx_token_lc$(1))
  If err$ <> "" Then cerror("Syntax error: !empty-lines directive " + err$)
End Sub

Sub process_include()
  If lx_num <> 2 Or lx_type(1) <> TK_STRING Then
    cerror("Syntax error: #Include expects a <file> argument")
  EndIf
  open_file(lx_string$(1))
  lx_parse_basic("' BEGIN:     " + lx_line$ + " " + String$(66 - Len(lx_line$), "-"))
End Sub

Sub process_indent()
  If lx_num > 2 Then cerror("Syntax error: !indent directive has too many arguments")
  op_set_indent_sz(lx_token_lc$(1))
  If err$ <> "" Then cerror("Syntax error: !indent directive " + err$)
End Sub

Sub process_replace()
  If lx_num <> 3 Then
    cerror("Syntax error: !replace directive expects <from> and <to> argumentss")
  EndIf
  map_put(replace$(), with$(), replace_sz, lx_token_lc$(1), lx_token_lc$(2))
End Sub

Sub process_set()
  Local t$ = lx_token_lc$(1)
  If lx_num <> 2 Or t$ = "" Then
    cerror("Syntax error: !set directive expects <flag> argument")
  EndIf
  If set_get(flags$(), flags_sz, t$) > -1 Then
    cerror("Error: flag '" + t$ + "' is already set")
  EndIf
  set_put(flags$(), flags_sz, t$)
End Sub

Sub process_spacing()
  If lx_num > 2 Then cerror("Syntax error: !spacing directive has too many arguments")
  op_set_spacing(lx_token_lc$(1))
  If err$ <> "" Then cerror("Syntax error: !spacing directive " + err$)
End Sub
