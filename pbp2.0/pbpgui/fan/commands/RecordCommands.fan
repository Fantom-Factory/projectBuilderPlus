/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using concurrent

//TODO: Need to add stronger type strength? Maybe not because these commands are administered by me.

class RecordCommands :Commands
{
  private PbpListener pbp
  new make(PbpListener pbp)
  {
    this.pbp = pbp
  }

  override ToolBar getToolbar()
  {
    ToolBar toolbar := ToolBar{}
    toolbar.addCommand(ClearSelection())
    toolbar.addCommand(EditRec(pbp))
    toolbar.addCommand(DeleteRec(pbp))

    return toolbar
  }

  static Command delete(PbpListener pbp)
  {
    return DeleteRec(pbp)
  }

  static Command edit(PbpListener pbp)
  {
    return EditRec(pbp)
  }

  static Command clear()
  {
    return ClearSelection()
  }

  static Command addSite(PbpListener pbp)
  {
    return AddSite(pbp)
  }

  static Command addEquip(PbpListener pbp)
  {
    return AddEquip(pbp)
  }

  static Command addPoint(PbpListener pbp)
  {
    return AddPoint(pbp)
  }
}

class EditRecFromTree : Command
{
  private PbpListener pbp
  new make(PbpListener pbp):super.makeLocale(Pod.find("projectBuilder"),"editRec")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace workspace := pbp.workspace
     //TODO Multi edit here.
     Tree? recTree := e.widget
     if(recTree!=null)
     {
       Record[] rec := [,]
       recTree.selected.each |node|
       {
         Record realRec := prj.database.getById((node as RecordTreeNode).record.id.toStr)
         rec.push(realRec)
       }
       if(rec.size-1 > 0)
       {
         List response := MultiRecordEditor(prj, rec, e.window).open
         if(response[0])
         {
           (recTree.model as RecordTreeModel).update()
           recTree.refreshAll
           workspace.siteExplorer.update(prj.database.getClassMap(Site#))
           workspace.siteExplorer.refreshAll
           workspace.equipExplorer.update(prj.database.getClassMap(Equip#))
           workspace.equipExplorer.refreshAll
           workspace.pointExplorer.update(prj.database.getClassMap(pbpcore::Point#))
           workspace.pointExplorer.refreshAll
         }
       }
       else if(rec.size > 0)
       {
         List response:= RecordEditor(prj, rec[0], e.window).open
         if(response[0])
         {
           (recTree.model as RecordTreeModel).update()
           recTree.refreshAll
           workspace.siteExplorer.update(prj.database.getClassMap(Site#))
           workspace.siteExplorer.refreshAll
           workspace.equipExplorer.update(prj.database.getClassMap(Equip#))
           workspace.equipExplorer.refreshAll
           workspace.pointExplorer.update(prj.database.getClassMap(pbpcore::Point#))
           workspace.pointExplorer.refreshAll
         }
       }
     }
     return

  }
}

internal class ClearSelection : Command
{
  new make():super.makeLocale(Pod.find("projectBuilder"),"clearRecSel")
  {
  }
  override Void invoked(Event? e)
  {
    recordExplorer := e.widget.parent.parent as RecordExplorer ?: throw Err("")
    recordExplorer.clearTableSelection
    recordExplorer.refreshAll
  }
}
