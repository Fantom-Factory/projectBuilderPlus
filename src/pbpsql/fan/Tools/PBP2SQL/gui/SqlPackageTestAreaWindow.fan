/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
using pbpcore
using concurrent

class SqlPackageTestAreaWindow : PbpWindow
{
  EdgePane mainWrapper := EdgePane{}
  TabPane  bottomPane := TabPane{}

  GridPane paneGridPane := GridPane{numCols = 3; Label{}, Label{text="Select Packages to test:"}, Label{text="Last Query Used"},}
  SqlPackage[] packages
  Str:SqlPackageQueryForm formMap := [:]

  Watcher[] watchers := [,]
  AtomicRef sqlrows
  AtomicRef qtext
  new make(Window? parentWindow, SqlPackage[] packages, AtomicRef rows, AtomicRef qtext) : super(parentWindow)
  {
    this.packages=packages
    this.sqlrows = rows
    this.qtext = qtext
  }

  override Obj? open()
  {
    Str titleT := "Sql Package Test Area -"
    ActorPool newPool := ActorPool()
    packages.each |package|
    {
      packagename := package.id["name"]
      AtomicBool enabler := AtomicBool(true)
      SqlPackageQueryForm form := SqlPackageQueryForm
        {
          name=packagename
          it.enabler=enabler
          pool=newPool
          watcher = getWatcher()
          queryText = qtext
        }
      paneGridPane.addAll(form.getForm)
      formMap.add(packagename,form)
      titleT = titleT+"${packagename}-"
      Table recTable := Table{model=RecTableModel([:])}
      SqlRecordTableUpdater(newPool, recTable, getWatcher(), sqlrows, ["package":package, "enabler":enabler]).send(null)
      bottomPane.add(Tab{text=packagename; recTable,})
    }
    mainWrapper.top = paneGridPane
    mainWrapper.center = bottomPane
    mainWrapper.bottom = ButtonGrid{numCols=1; Button(Dialog.ok),}
    content=mainWrapper
    this.title = titleT
    super.open()
    newPool.stop()
    Str:Str statementMap := [:]
    formMap.each |v,k|
    {
      statementMap.add(k,v.statement)
    }
    return SqlPackageDeploymentScheme{
      it.packages=this.packages
      it.formMap=statementMap
    }
  }


Watcher getWatcher()
{
  watchers.push(Watcher())
  return watchers.peek
}

Void notifyChange()
{
  watchers.each | watcher|
  {
    watcher.set()
  }
}
}



