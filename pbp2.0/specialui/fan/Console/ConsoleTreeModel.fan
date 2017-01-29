/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class ConsoleTreeModel : TreeModel
{
  Session[] sessions
  Obj? lastNode

  new make(Session[] sessions)
  {
    this.sessions = sessions
    lastNode = roots.last
  }

  override Color? fg(Obj node)
  {
    switch(node.typeof)
    {
      case Session#:
        return Color.makeRgb(134,196,136)
      case TextCommand#:
        return Color.black
      case Response#:
        return Color.blue
      case Error#:
        return Color.red
      default:
        return null
    }
  }

  override Str text(Obj node)
  {
    switch(node.typeof)
    {
      case Session#:
        return node->text.toStr
      case TextCommand#:
        return node->text.toStr+" {${node->opts}}  ${node->ts}"
      default:
        return ""
     }
  }

  override Obj[] children(Obj node)
  {
    if(node->children != null)
    {
      return node->children
    }
    else
    {
      return [,]
    }
  }

  override Obj[] roots()
  {
    return sessions
  }

  Void updateTree(Session[] sessions)
  {
    this.sessions = sessions
  }
}







