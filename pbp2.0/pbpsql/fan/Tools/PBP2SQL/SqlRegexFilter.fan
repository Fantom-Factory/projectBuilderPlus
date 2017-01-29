/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
const class SqlRegexFilter : SqlFilter
{
  const Str regEx

  new make(Str regEx)
  {
    this.regEx = regEx
  }

  override Bool filter(Str s)
  {
    return Regex.fromStr(regEx).matches(s)
  }
}
