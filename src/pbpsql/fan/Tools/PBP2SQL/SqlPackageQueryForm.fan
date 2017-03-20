/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using concurrent
using pbpcore

@Serializable
class SqlPackageQueryForm
{
  Str name
  Str statement := ""
  AtomicBool enabler
  ActorPool pool
  Watcher watcher
  AtomicRef queryText

  Button? disableButton
  Label? packageNameLabel
  Text? recentQueryText

  new make(|This| f)
  {
    f(this)
  }

  Widget[] getForm()
  {
    disableButton = Button{
      mode=ButtonMode.check
      selected=true
      onAction.add |e|
      {
        enabler.getAndSet((e.widget as Button).selected)
      }
      }
    packageNameLabel = Label{text=name}
    recentQueryText = Text{text=queryText.val
      onModify.add|e|
      {
        statement=(e.widget as Text).text
      }
    }
    QueryWatcher(recentQueryText, watcher, queryText, enabler, pool).send(null)
    return [disableButton, packageNameLabel, recentQueryText]
  }

}

const class QueryWatcher : Actor
{

  const Str handle := Uuid().toStr
  const Watcher watcher
  const AtomicRef queryText
  const AtomicBool enabler
  new make(Text label, Watcher watcher, AtomicRef queryText, AtomicBool enabler, ActorPool pool) : super(pool)
  {
    Actor.locals[handle] = label
    this.watcher = watcher
    this.queryText = queryText
    this.enabler = enabler
    sendLater(1sec, null)
  }

  override Obj? receive(Obj? msg)
  {
    if(watcher.check() && enabler.val==true)
    {
      Desktop.callAsync |->| { update }
    }
    sendLater(10ms, null)
    return null
  }

  Void update()
  {
    label := Actor.locals[handle] as Text
    if (label != null)
    {
      label.text = queryText.val
    }
  }

}
