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

class SaveSqlPackage : Command
{
  SqlPackageEditPane[] panes
  SqlProcessor processor
  new make(SqlPackageEditPane[] panes, SqlProcessor processor) : super.makeLocale(Pod.of(this), "saveSqlPackage")
  {
    this.panes = panes
    this.processor = processor
  }

  override Void invoked(Event? e)
  {
    SqlPackage[] sqlPacks := [,]
    panes.each |pane|
    {
      sqlPacks.push(processor.processEditPane(pane))
    }
    File file := FileDialog{
      it.mode = FileDialogMode.saveFile
      filterExts = ["*.sqlpack"]
      dir = (Env.cur.homeDir+`resources/sql/`)
      }.open(e.window)
    file.writeObj(sqlPacks)
  }
}

class TestSqlPackage : Command
{
  SqlPackageEditPane[] panes
  SqlProcessor processor
  Watcher watcher
  AtomicRef tableRef
  AtomicRef queryRef
  new make(SqlPackageEditPane[] panes, SqlProcessor processor, SqlConnWrapper conn) : super.makeLocale(Pod.of(this), "testSqlPackage")
  {
    this.panes = panes
    this.processor = processor
    this.watcher = conn.worker.watcherRows
    this.tableRef = conn.worker.rowVals
    this.queryRef = conn.worker.querVal
  }

  override Void invoked(Event? e)
  {
    SqlPackage[] sqlPacks := [,]
    panes.each |pane|
    {
      sqlPacks.push(processor.processEditPane(pane))
    }
    ActorPool newPool := ActorPool()
    SqlPackageTestAreaWindow window := SqlPackageTestAreaWindow(e.window,sqlPacks,tableRef,queryRef)
    SqlPackageTestAreaWindowUpdater(window, watcher, newPool).send(null)
    SqlPackageDeploymentScheme scheme := window.open()
    newPool.stop()
    Env.cur.homeDir.createFile("test").writeObj(scheme)
  }
}

class AddRegexRuleCommand : Command
{
  SqlPackageEditPane sqlEditPane
  new make(SqlPackageEditPane sqlEditPane) : super.makeLocale(Pod.of(this), "AddRegexRule")
  {
    this.sqlEditPane = sqlEditPane
  }

  override Void invoked(Event? e)
  {
    SqlRegExRule regexRule := SqlRegExRule([,],sqlEditPane.listRef)
    sqlEditPane.blobs.push(regexRule)
    sqlEditPane.regExRuleGridPane.addAll(regexRule.getForm)
    sqlEditPane.regExRuleGridPane.relayout
    sqlEditPane.updateableActors.push(SqlColSelectUpdater(regexRule.colSelector, sqlEditPane.getWatcher(), sqlEditPane.newPool))
    sqlEditPane.updateableActors.peek.send(null)
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.relayout
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.parent.relayout
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.parent.parent.relayout
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.parent.parent.parent.relayout
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.parent.parent.parent.parent.relayout
  }
}

class AddTagsToRuleCommand : Command
{
  SqlRegExRule sqlRule
  new make(SqlRegExRule sqlRule) : super.makeLocale(Pod.of(this), "addTagsToRule")
  {
    this.sqlRule = sqlRule
  }

  override Void invoked(Event? e)
  {
    Tag[] tagPicker := TagPicker(e.window).open
    sqlRule.tags.addAll(tagPicker)
    sqlRule.tagsDisplay.items=sqlRule.tags//.toStr
    sqlRule.tagsDisplay.relayout
    sqlRule.tagsDisplay.parent.relayout
    sqlRule.tagsDisplay.parent.parent.relayout
    sqlRule.tagsDisplay.parent.parent.parent.relayout
    sqlRule.tagsDisplay.parent.parent.parent.parent.relayout
  }

}

class AddStrMatchRuleCommand : Command
{
  SqlPackageEditPane sqlEditPane
  new make(SqlPackageEditPane sqlEditPane) : super.makeLocale(Pod.of(this), "AddStrMatchRule")
  {
    this.sqlEditPane = sqlEditPane
  }

  override Void invoked(Event? e)
  {
    SqlColSelector newselector := SqlColSelector(sqlEditPane.listRef)
    sqlEditPane.strMatRuleGridPane.add(newselector)
    sqlEditPane.strMatRuleGridPane.add(Text{})
    sqlEditPane.strMatRuleGridPane.relayout
    sqlEditPane.updateableActors.push(SqlColSelectUpdater(newselector, sqlEditPane.getWatcher(), sqlEditPane.newPool))
    sqlEditPane.updateableActors.peek.send(null)
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.relayout
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.parent.relayout
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.parent.parent.relayout
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.parent.parent.parent.relayout
    sqlEditPane.additionalTagInstruction.fieldWrapper.parent.parent.parent.parent.parent.relayout
  }
}
