/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

@Serializable
class DisRuleValue : DisTagRule
{
  const Tag tagToCompare
  new make(|This| f)
  {
    f(this)
  }

  override Bool check(Record rec)
  {
    Tag? tofind := rec.get(tagToCompare.name)
    if(tofind!=null && tofind.val == tagToCompare.val)
    {
      return true
    }
    else
    {
      return false
    }
  }

  override Tag getTag()
  {
    return tagToCompare
  }

  override Str desc()
  {
    return "Checks for the tag: " + tagToCompare.name + " and matches the value"
  }
}
