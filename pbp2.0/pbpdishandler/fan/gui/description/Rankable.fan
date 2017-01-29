/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

mixin Rankable
{
  List upgrade(List list, Int position)
  {
    list = list.swap(position, position-1)
    return list
  }

  List downgrade(List list, Int position)
  {
    list = list.swap(position, (position+1)%list.size)
    return list
  }
}
