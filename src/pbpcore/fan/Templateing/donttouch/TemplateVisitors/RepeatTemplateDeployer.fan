/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////




const class RepeatTemplateDeployer : TemplateDeployer
{
  const Int repeat
  new make(Int? repeat := 1)
  {
    if(repeat!=null && repeat!=0)
    {
      this.repeat = repeat
    }
    else
    {
      this.repeat = 1
    }
  }
  override Int size()
  {
    return repeat
  }
  override Obj? visit(Str:Obj params)
  {
    Record[] recs := [,]
    repeat.times |->|
    {
      recs.addAll( TemplateEngine.replicateTemplateTree(params["template"], params["opts"])["newRecs"]->vals)
    }
    return recs
  }
}
