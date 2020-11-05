' Copyright (c) 2020 Thomas Hugo Williams

Option Explicit On
Option Default Integer
Option Base 0

#Include "../error.inc"
#Include "../file.inc"
#Include "../list.inc"
#Include "../set.inc"
#Include "../../sptest/unittest.inc"

add_test("test_init")
add_test("test_add")
add_test("test_clear")
add_test("test_get")
add_test("test_insert")
add_test("test_remove")
add_test("test_pop")
add_test("test_push")
add_test("test_set")
add_test("test_sort")

run_tests()

End

Sub setup_test()
End Sub

Sub teardown_test()
End Sub

Function test_init()
  Local my_list$(list.new%(20))
  list.init(my_list$())

  assert_equals(20, list.capacity%(my_list$()))
  assert_equals(0, list.size%(my_list$()))
  Local i
  For i = 0 To 19
    assert_string_equals(list.NULL$, my_list$(i))
  Next
End Function

Function test_add()
  Local my_list$(list.new%(20))
  list.init(my_list$())

  list.add(my_list$(), "foo")
  list.add(my_list$(), "bar")

  assert_equals(2, list.size%(my_list$()))
  assert_string_equals("foo", my_list$(0))
  assert_string_equals("bar", my_list$(1))

  assert_equals(20, list.capacity%(my_list$()))
End Function

Function test_clear()
  Local my_list$(list.new%(20))
  list.init(my_list$())
  list.add(my_list$(), "aa")
  list.add(my_list$(), "bb")
  list.add(my_list$(), "cc")

  list.clear(my_list$())

  assert_equals(0, list.size%(my_list$()))
  Local i
  For i = 0 To 19
    assert_string_equals(list.NULL$, my_list$(i))
  Next

  assert_equals(20, list.capacity%(my_list$()))
End Function

Function test_get()
  Local my_list$(list.new%(20))
  list.init(my_list$())
  list.add(my_list$(), "aa")
  list.add(my_list$(), "bb")
  list.add(my_list$(), "cc")

  assert_equals(20, list.capacity%(my_list$()))
  assert_equals(3, list.size%(my_list$()))
  assert_string_equals("aa", list.get$(my_list$(), 0))
  assert_string_equals("bb", list.get$(my_list$(), 1))
  assert_string_equals("cc", list.get$(my_list$(), 2))

  On Error Ignore
  Local s$ = list.get$(my_list$(), 3)
  assert_true(InStr(Mm.ErrMsg$, "index out of bounds: 3") > 0)
  On Error Abort
End Function

Function test_insert()
  Local my_list$(list.new%(20))
  list.init(my_list$())
  list.add(my_list$(), "foo")
  list.add(my_list$(), "bar")

  list.insert(my_list$(), 0, "wom")
  assert_equals(3, list.size%(my_list$()))
  assert_string_equals("wom", my_list$(0))
  assert_string_equals("foo", my_list$(1))
  assert_string_equals("bar", my_list$(2))

  list.insert(my_list$(), 1, "bat")
  assert_equals(4, list.size%(my_list$()))
  assert_string_equals("wom", my_list$(0))
  assert_string_equals("bat", my_list$(1))
  assert_string_equals("foo", my_list$(2))
  assert_string_equals("bar", my_list$(3))

  list.insert(my_list$(), 4, "snafu")
  assert_equals(5, list.size%(my_list$()))
  assert_string_equals("wom", my_list$(0))
  assert_string_equals("bat", my_list$(1))
  assert_string_equals("foo", my_list$(2))
  assert_string_equals("bar", my_list$(3))
  assert_string_equals("snafu", my_list$(4))

  assert_equals(20, list.capacity%(my_list$()))
End Function

Function test_pop()
  Local my_list$(list.new%(20))
  list.init(my_list$())
  list.add(my_list$(), "foo")
  list.add(my_list$(), "bar")

  assert_string_equals("bar", list.pop$(my_list$()))
  assert_equals(1, list.size%(my_list$()))
  assert_string_equals("foo", list.pop$(my_list$()))
  assert_equals(0, list.size%(my_list$()))
  assert_string_equals(list.NULL$, list.pop$(my_list$()))
  assert_equals(0, list.size%(my_list$()))
  assert_string_equals(list.NULL$, list.pop$(my_list$()))
  assert_equals(0, list.size%(my_list$()))

  assert_equals(20, list.capacity%(my_list$()))
End Function

Function test_push()
  Local my_list$(list.new%(20))
  list.init(my_list$())

  list.push(my_list$(), "foo")
  list.push(my_list$(), "bar")

  assert_equals(2, list.size%(my_list$()))
  assert_string_equals("foo", my_list$(0))
  assert_string_equals("bar", my_list$(1))

  assert_equals(20, list.capacity%(my_list$()))
End Function

Function test_remove()
  Local my_list$(list.new%(20))
  list.init(my_list$())
  list.add(my_list$(), "aa")
  list.add(my_list$(), "bb")
  list.add(my_list$(), "cc")
  list.add(my_list$(), "dd")

  list.remove(my_list$(), 1)
  assert_equals(3, list.size%(my_list$()))
  assert_string_equals("aa", my_list$(0))
  assert_string_equals("cc", my_list$(1))
  assert_string_equals("dd", my_list$(2))

  list.remove(my_list$(), 0)
  assert_equals(2, list.size%(my_list$()))
  assert_string_equals("cc", my_list$(0))
  assert_string_equals("dd", my_list$(1))

  list.remove(my_list$(), 1)
  assert_equals(1, list.size%(my_list$()))
  assert_string_equals("cc", my_list$(0))

  list.remove(my_list$(), 0)
  assert_equals(0, list.size%(my_list$()))

  assert_equals(20, list.capacity%(my_list$()))
End Function

Function test_set()
  Local my_list$(list.new%(20))
  list.init(my_list$())
  list.add(my_list$(), "aa")
  list.add(my_list$(), "bb")
  list.add(my_list$(), "cc")

  list.set(my_list$(), 0, "00")
  list.set(my_list$(), 1, "11")
  list.set(my_list$(), 2, "22")

  assert_equals(20, list.capacity%(my_list$()))
  assert_equals(3, list.size%(my_list$()))
  assert_string_equals("00", my_list$(0))
  assert_string_equals("11", my_list$(1))
  assert_string_equals("22", my_list$(2))

  On Error Ignore
  list.set(my_list$(), 3, "33")
  assert_true(InStr(Mm.ErrMsg$, "index out of bounds: 3") > 0)
  On Error Abort
End Function

Function test_sort()
  Local my_list$(list.new%(20))
  list.init(my_list$())
  list.add(my_list$(), "bb")
  list.add(my_list$(), "dd")
  list.add(my_list$(), "cc")
  list.add(my_list$(), "aa")

  list.sort(my_list$())

  assert_equals(20, list.capacity%(my_list$()))
  assert_equals(4, list.size%(my_list$()))
  assert_string_equals("aa", my_list$(0))
  assert_string_equals("bb", my_list$(1))
  assert_string_equals("cc", my_list$(2))
  assert_string_equals("dd", my_list$(3))
End Function
