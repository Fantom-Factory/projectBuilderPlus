/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

@Serializable
class Session
{
  Str text
  TextCommand[] children

  @Transient Int previousIndex := 0
  @Transient Int nextIndex := 0
  @Transient Int currentIndex := 0

  new make(|This| f)
    {
      f(this)
    }

  @Transient
  static Session fromJson(Str:Obj? data)
  {
    TextCommand[] commands := [,]

    data["children"]->each |command|{
      commands.push(TextCommand.fromJson(command))
      }

    return Session
      {
      it.text = data["text"]
      it.children = commands
      }

  }

  @Transient
  Void addTextCommand(Str content)
  {
    children.push(
    TextCommand{
          it.text=Regex.fromStr(":::").split(content)[0];
          it.ts=Regex.fromStr(":::").split(content)[1];
          it.opts=Regex.fromStr(":::").split(content)[2];
          it.children=[,];
        }
      )
    currentIndex = children.size
    previousIndex = currentIndex - 1
    nextIndex = currentIndex + 1

  }

  @Transient
  TextCommand? getPrevious()
  {
    Bool outofbounds := false
    try
    {
        if(previousIndex >= 0)
       {
         return children[previousIndex]
       }
       else
       {
         outofbounds = true
         return null
       }
    }
    catch(Err e)
    {
      outofbounds = true
      return null
    }
    finally
    {
      if(!outofbounds)
      {
      currentIndex = previousIndex
      previousIndex = currentIndex - 1
      nextIndex = currentIndex + 1
      }
    }
  }

  @Transient
  TextCommand? getNext()
  {
    Bool outofbounds := false
    try
    {
       if(nextIndex > 0)
       {
         return children[nextIndex]
       }
       else
       {
         outofbounds = true
         return null
       }
    }
    catch(Err e)
    {
      outofbounds = true
      return null
    }
     finally
    {
      if(!outofbounds)
      {
      currentIndex = nextIndex
      previousIndex = currentIndex - 1
      nextIndex = currentIndex + 1
      }
    }
  }


}
