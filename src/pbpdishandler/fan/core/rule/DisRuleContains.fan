/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

@Serializable
class DisRuleContains : DisTagRule
{
  const Tag tagToFind
  new make(|This| f)
  {
    f(this)
  }

  override Bool check(Record rec)
  {
    Tag? tofind := rec.get(tagToFind.name)
    if(tofind!=null){return true}
    else{return false}
  }

  override Tag getTag()
  {
    return tagToFind
  }

  override Str desc()
  {
    return "Checks for the tag: " + tagToFind.name
  }

}
