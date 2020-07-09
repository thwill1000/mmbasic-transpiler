' Copyright (c) 2020 Thomas Hugo Williams

Option Explicit On
Option Default Integer

#Include "../unittest.inc"
#Include "../lexer.inc"

Cls

lx_load_keywords()

ut_add_test("test_tokenise")
ut_add_test("test_binary_literals")
ut_add_test("test_comments")
ut_add_test("test_directives")
ut_add_test("test_hexadecimal_literals")
ut_add_test("test_identifiers")
ut_add_test("test_includes")
ut_add_test("test_integer_literals")
ut_add_test("test_keywords")
ut_add_test("test_octal_literals")
ut_add_test("test_real_literals")
ut_add_test("test_string_literals")
ut_add_test("test_string_no_closing_quote")
ut_add_test("test_symbols")
ut_add_test("test_get_number")

ut_run_tests()

End

Function test_tokenise()
  lx_tokenise("  foo    bar/wom " + Chr$(34) + "bat" + Chr$(34) + "   ")

  expect_success(3)
  expect_tk(0, LX_IDENTIFIER, "foo")
  expect_tk(1, LX_IDENTIFIER, "bar/wom")
  expect_tk(2, LX_IDENTIFIER, Chr$(34) + "bat" + Chr$(34))
End Function

Function test_binary_literals()
  lx_parse_line("&b1001001")

  expect_success(1)
  expect_tk(0, LX_NUMBER, "&b1001001")

  lx_parse_line("&B0123456789")

  expect_success(2)
  expect_tk(0, LX_NUMBER, "&B01")
  expect_tk(1, LX_NUMBER, "23456789")
End Function

Function test_comments()
  lx_parse_line("' This is a comment")

  expect_success(1)
  expect_tk(0, LX_COMMENT, "' This is a comment");
End Function

Function test_directives()
  lx_parse_line("'!comment_if foo")

  expect_success(2)
  expect_tk(0, LX_DIRECTIVE, "'!comment_if")
  expect_tk(1, LX_IDENTIFIER, "foo")
End Function

Function test_includes()
  lx_parse_line("#Include " + Chr$(34) + "foo.inc" + Chr$(34))

  expect_success(2)
  expect_tk(0, LX_KEYWORD, "#Include")
  expect_tk(1, LX_STRING, Chr$(34) + "foo.inc" + Chr$(34))
End Function

Function test_hexadecimal_literals()
  lx_parse_line("&hABCDEF")

  expect_success(1)
  expect_tk(0, LX_NUMBER, "&hABCDEF")

  lx_parse_line("&Habcdefghijklmn")

  expect_success(2)
  expect_tk(0, LX_NUMBER, "&Habcdef")
  expect_tk(1, LX_IDENTIFIER, "ghijklmn")
End Function

Function test_identifiers()
  lx_parse_line("xx s$ foo.bar wom.bat$")

  expect_success(4)
  expect_tk(0, LX_IDENTIFIER, "xx")
  expect_tk(1, LX_IDENTIFIER, "s$")
  expect_tk(2, LX_IDENTIFIER, "foo.bar")
  expect_tk(3, LX_IDENTIFIER, "wom.bat$")
End Function

Function test_integer_literals()
  lx_parse_line("421")

  expect_success(1)
  expect_tk(0, LX_NUMBER, "421")
End Function

Function test_keywords()
  lx_parse_line("For Next Do Loop Chr$")

  expect_success(5)
  expect_tk(0, LX_KEYWORD, "For")
  expect_tk(1, LX_KEYWORD, "Next")
  expect_tk(2, LX_KEYWORD, "Do")
  expect_tk(3, LX_KEYWORD, "Loop")
  expect_tk(4, LX_KEYWORD, "Chr$")

  lx_parse_line("  #gps @ YELLOW  ")
  expect_success(3)
  expect_tk(0, LX_KEYWORD, "#gps")
  expect_tk(1, LX_KEYWORD, "@")
  expect_tk(2, LX_KEYWORD, "YELLOW")
End Function

Function test_octal_literals()
  lx_parse_line("&O1234")

  expect_success(1)
  expect_tk(0, LX_NUMBER, "&O1234")

  lx_parse_line("&O123456789")

  expect_success(2)
  expect_tk(0, LX_NUMBER, "&O1234567")
  expect_tk(1, LX_NUMBER, "89")
End Function

Function test_real_literals()
  lx_parse_line("3.421")

  expect_success(1)
  expect_tk(0, LX_NUMBER, "3.421")

  lx_parse_line("3.421e5")

  expect_success(1)
  expect_tk(0, LX_NUMBER, "3.421e5")

  lx_parse_line("3.421e-17")

  expect_success(1)
  expect_tk(0, LX_NUMBER, "3.421e-17")

  lx_parse_line("3.421e+17")

  expect_success(1)
  expect_tk(0, LX_NUMBER, "3.421e+17")

  lx_parse_line(".3421")

  expect_success(1)
  expect_tk(0, LX_NUMBER, ".3421")
End Function

Function test_string_literals()
  lx_parse_line(Chr$(34) + "This is a string" + Chr$(34))

  expect_success(1)
  expect_tk(0, LX_STRING, Chr$(34) + "This is a string" + Chr$(34))
End Function

Function test_string_no_closing_quote()
  lx_parse_line(Chr$(34) + "String literal with no closing quote")

  expect_error("No closing quote")
End Function

Function test_symbols()
  lx_parse_line("a=b/c*d\e<=f=<g>=h=>i:j;k,l<m>n")

  expect_success(27)
  expect_tk(0, LX_IDENTIFIER, "a")
  expect_tk(1, LX_SYMBOL, "=")
  expect_tk(2, LX_IDENTIFIER, "b")
  expect_tk(3, LX_SYMBOL, "/")
  expect_tk(4, LX_IDENTIFIER, "c")
  expect_tk(5, LX_SYMBOL, "*")
  expect_tk(6, LX_IDENTIFIER, "d")
  expect_tk(7, LX_SYMBOL, "\")
  expect_tk(8, LX_IDENTIFIER, "e")
  expect_tk(9, LX_SYMBOL, "<=")
  expect_tk(10, LX_IDENTIFIER, "f")
  expect_tk(11, LX_SYMBOL, "=<")
  expect_tk(12, LX_IDENTIFIER, "g")
  expect_tk(13, LX_SYMBOL, ">=")
  expect_tk(14, LX_IDENTIFIER, "h")
  expect_tk(15, LX_SYMBOL, "=>")
  expect_tk(16, LX_IDENTIFIER, "i")
  expect_tk(17, LX_SYMBOL, ":")
  expect_tk(18, LX_IDENTIFIER, "j")
  expect_tk(19, LX_SYMBOL, ";")
  expect_tk(20, LX_IDENTIFIER, "k")
  expect_tk(21, LX_SYMBOL, ",")
  expect_tk(22, LX_IDENTIFIER, "l")
  expect_tk(23, LX_SYMBOL, "<")
  expect_tk(24, LX_IDENTIFIER, "m")
  expect_tk(25, LX_SYMBOL, ">")
  expect_tk(26, LX_IDENTIFIER, "n")

  lx_parse_line("a$(i + 1)")
  expect_success(6)
  expect_tk(0, LX_IDENTIFIER, "a$")
  expect_tk(1, LX_SYMBOL, "(")
  expect_tk(2, LX_IDENTIFIER, "i")
  expect_tk(3, LX_SYMBOL, "+")
  expect_tk(4, LX_NUMBER, "1")
  expect_tk(5, LX_SYMBOL, ")")

  lx_parse_line("xx=xx+1")
  expect_success(5)
  expect_tk(0, LX_IDENTIFIER, "xx")
  expect_tk(1, LX_SYMBOL, "=")
  expect_tk(2, LX_IDENTIFIER, "xx")
  expect_tk(3, LX_SYMBOL, "+")
  expect_tk(4, LX_NUMBER, "1")

End Function

Function test_get_number()
  lx_parse_line("1 2 3.14 3.14e-15")
  ut_assert_real_equals(1, lx_get_number(0))
  ut_assert_real_equals(2, lx_get_number(1))
  ut_assert_real_equals(3.14, lx_get_number(2))
  ut_assert_real_equals(3.14e-15, lx_get_number(3))
End Function

Sub expect_success(num)
  ut_assert(lx_error$ = "", "unexpected lexer error: " + lx_error$)
  ut_assert(lx_num = num, "expected " + Str$(num) + " tokens, found " + Str$(lx_num))
End Sub

Sub expect_tk(i, type, s$)
  ut_assert(lx_type(i) = type, "expected type " + Str$(type) + ", found " + Str$(lx_type(i)))
  Local actual$ = lx_token$(i)
  ut_assert(actual$ = s$, "excepted " + s$ + ", found " + actual$)
End Sub

Sub expect_error(msg$)
  ut_assert(lx_error$ = msg$, "missing expected error: " + msg$)
End Sub
