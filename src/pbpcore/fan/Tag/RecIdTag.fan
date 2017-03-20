/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack

const class RefTag : Tag {
  const Str kind := "Ref"
  new make(|This| f) : super(f){
    if(this.val != null && this.val.typeof == Str#)
    {
      this.val = Ref.fromStr(this.val)
    }
  }
}
