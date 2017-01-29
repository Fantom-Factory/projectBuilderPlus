/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


**
** ConnData
**
@Serializable
class ConnData
{
  private Str:Str map := [:]

  Void set(Str k, Str v) {map[k]=v}

  Str get(Str k) {map[k]}
}
