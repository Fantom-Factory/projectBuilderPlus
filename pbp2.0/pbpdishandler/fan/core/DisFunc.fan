/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

@Serializable
class DisFunc
{
  Str displayName := "New_Display_Function"
  DisRule[] rules
  DisApply[] applies
  new make(|This| f)
  {
    f(this)
  }

  Record invoke(Record rec)
  {
    Bool tocheck := true

    rules.each |rule|
    {
      tocheck = tocheck.and(rule.check(rec))
    }

    if(tocheck)
    {
      Record working := rec.add(StrTag{name="dis"; val=""})
      Tag disTag := working.get("dis")
      applies.each |app|
      {
        disTag = app.apply(working ,disTag)
      }
      Record newRec := working.add(disTag)
      return newRec
    }
    else
    {
      return rec
    }
  }

  Tag[] getRules()
  {
    Tag[] toReturn := [,]
    rules.each |rule|
    {
        if (rule is DisTagRule) toReturn.push((rule as DisTagRule).getTag)
    }
    return toReturn
  }

  Str[] getUserValues()
  {
    Str[] uservals := [,]
    applies.findAll |DisApply apply->Bool| {return apply.typeof == DisApplyUser#}.each |useapply|
    {
      uservals.push((useapply as DisApplyUser).getVal)
    }
    return uservals
  }

  Tag[] getTagValues()
  {
    Tag[] tagvals := [,]
    applies.findAll |DisApply apply->Bool| {return apply.typeof == DisApplyTag#}.each |tagapply|
    {
      tagvals.push((tagapply as DisApplyTag).getTag)
    }
    return tagvals
  }

}
