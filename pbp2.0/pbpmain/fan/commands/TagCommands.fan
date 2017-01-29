/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpgui

//TODO: Need to add stronger type strength? Maybe not because these commands are administered by me.

class TagCommands : Commands
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
  }

  override ToolBar getToolbar()
  {
    ToolBar toolbar := ToolBar{}
    toolbar.addCommand(OpenTagLib(pbp))
    return toolbar
  }
}

class OpenTagLib : Command
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp):super.makeLocale(Pod.of(this),"libEditor")
  {
    this.pbp = pbp
  }
  override Void invoked(Event? e)
  {
    LibEditor libeditor := LibEditor(e.window, FileUtil.getTagDir)
    libeditor.name = "Tag"
    libeditor.newLibButton = Button(NewTagLib(pbp, libeditor.libDir))
    libeditor.addLibButton = Button(AddTagLib(pbp, libeditor.libDir))
    libeditor.deleteLibButton = Button(DeleteTagLib(pbp, libeditor.libDir))
    libeditor.editLibButton = Button(EditTagLib(pbp))
    libeditor.makeLibButton = Button(DefaultTagLib(pbp, libeditor.libDir))
    libeditor.libTable.model = TagLibTableModel(libeditor.libDir, TagUtil.loadDefaultLib(libeditor.libDir))
    libeditor.open
  }
}

class NewTagLib : Command
{
  File tagDir
  ProjectBuilder pbp
  new make(ProjectBuilder pbp, File tagDir):super.makeLocale(Pod.of(this),"newLib")
  {
    this.pbp = pbp
    this.tagDir = tagDir
  }

  override Void invoked(Event? e)
  {
    libname := Dialog.openPromptStr(e.window,"What would you like to call this Tag Library?")
    if (libname != null)
    {
        tagfile := tagDir.createFile(libname+".taglib")
        TagLib{
          it.tagDir = this.tagDir
          it.tagLibFile = tagfile
        }.write

        (pbp.coreWidgets[pbp.customTagsExpHandle] as TagExplorer).setToolbarWithCombo(TagCommands(pbp).getToolbar, TagUtil().getTagLibCombo)

        libEditor := e.window as LibEditor ?: throw Err("e.window is not ${LibEditor#}")

        (libEditor.libTable.model as TagLibTableModel).update()
        libEditor.libTable.refreshAll
     }
  }
}

class DefaultTagLib : Command
{
  File tagDir
  ProjectBuilder pbp
  new make(ProjectBuilder pbp, File tagDir):super.makeLocale(Pod.of(this),"defLib")
  {
    this.pbp = pbp
    this.tagDir = tagDir
  }

  override Void invoked(Event? e)
  {
    libEditor := e.window as LibEditor ?: throw Err("e.window is not ${LibEditor#}")

    selected := libEditor.libTable.selected.first
    if(selected != null)
    {
      File file := (libEditor.libTable.model as TagLibTableModel).getLibFile(selected)

      if (TagUtil.saveDefaultLib(libEditor.libDir, file))
      {
          (libEditor.libTable.model as TagLibTableModel).defaultLib = file
      }
      else
      {
          (libEditor.libTable.model as TagLibTableModel).defaultLib = null
      }

      libEditor.libTable.refreshAll
    }
  }
}

class AddTagLib : Command
{
  File tagDir
  ProjectBuilder pbp
  new make(ProjectBuilder pbp, File tagDir):super.makeLocale(Pod.of(this),"addLib")
  {
    this.pbp = pbp
    this.tagDir = tagDir
  }
  override Void invoked(Event? e)
  {
    libEditor := e.window as LibEditor ?: throw Err("e.window is not ${LibEditor#}")

    File? file := FileDialog{
      it.mode = FileDialogMode.openFile
      it.filterExts = ["*.taglib"]
    }.open(e.window)

    if(file!=null)
    {
      file.copyTo(tagDir)
    }
    (pbp.coreWidgets[pbp.customTagsExpHandle] as TagExplorer).setToolbarWithCombo(TagCommands(pbp).getToolbar, TagUtil().getTagLibCombo)
    (libEditor.libTable.model as TagLibTableModel).update()
    libEditor.libTable.refreshAll
  }
}

class DeleteTagLib : Command
{
  static const Str[] protectedLibs := ["standard", "hisremove"]

  File tagDir
  ProjectBuilder pbp
  new make(ProjectBuilder pbp, File tagDir):super.makeLocale(Pod.of(this),"delLib")
  {
    this.pbp = pbp
    this.tagDir = tagDir
  }
  override Void invoked(Event? e)
  {
    libEditor := e.window as LibEditor ?: throw Err("e.window is not ${LibEditor#}")

    Int[] selected := libEditor.libTable.selected
    File taglibfile := (libEditor.libTable.model as TagLibTableModel).getLibFile(selected.first)
    // Protecting "standard" libraries from deletion
    if(protectedLibs.contains(taglibfile.basename.lower))
      return
    resp := Dialog.openWarn(e.window,"Are you sure you would like to delete the library ${taglibfile}?",null,Dialog.yesNo)
    if(resp == Dialog.yes)
    {
      taglibfile.delete
    }
    (pbp.coreWidgets[pbp.customTagsExpHandle] as TagExplorer).setToolbarWithCombo(TagCommands(pbp).getToolbar, TagUtil().getTagLibCombo)
    (libEditor.libTable.model as TagLibTableModel).update()
    libEditor.libTable.refreshAll
  }
}

class EditTagLib : Command
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp): super.makeLocale(Pod.of(this), "editLib")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? e)
  {
    libEditor := e.window as LibEditor ?: throw Err("e.window is not ${LibEditor#}")

    Int[] selected := libEditor.libTable.selected
    File taglibfile := (libEditor.libTable.model as TagLibTableModel).getLibFile(selected.first)
    edit(e.window, taglibfile)
  }

  Void edit(Window? w, File taglibfile)
  {
    TagLib taglib := TagLib.fromXml(taglibfile)

    TagEditor tageditor := TagEditor(w,taglib)

    toolbar := ToolBar()
    toolbar.addCommand(AddTagToEditor(tageditor))

    tageditor.contentWrapper.top = toolbar

    tageditor.contentWrapper.bottom = GridPane
      {
        numCols=2;
        halignPane = Halign.right;
        Button(SaveTagsToLib(tageditor)),
        Button{text="Close"; onAction.add|f|{f.window.close}},
      }
    tageditor.open
    TagExplorer tagExp := pbp.coreWidgets[pbp.customTagsExpHandle]
    if(tagExp.tagTableModel.tagLib.tagLibFile.basename == taglibfile.basename)
    {
      tagExp.tagTableModel.update(taglibfile)
      tagExp.tagTable.refreshAll
    }
  }
}

class AddTagToEditor : Command
{
  TagEditor tageditor
  new make(TagEditor tageditor) : super.makeLocale(Pod.of(this),"addTagsToLib")
  {
    this.tageditor = tageditor
  }

  override Void invoked(Event? e)
  {
    tageditor.tageditpane.add(NewTagMaker())
    tageditor.tageditpane.relayout
    tageditor.tageditpane.parent.relayout
    tageditor.tageditpane.parent.parent.relayout
  }
}

class SaveTagsToLib : Command
{
  TagEditor tageditor
  new make(TagEditor tageditor) : super.makeLocale(Pod.of(this),"saveTagsToLib")
  {
    this.tageditor = tageditor
  }

  override Void invoked(Event? e)
  {
    TagExplorer explorer := tageditor.tagExp
    tageditor.tageditpane.children.each |tagmaker|
    {
      Tag? newtag := null
      if(tagmaker is EditTagMaker)
      {
        newtag = (tagmaker as EditTagMaker).getNewTag
        explorer.tagTableModel.tagLib.tags.remove((tagmaker as EditTagMaker).tag)
      }
      else if (tagmaker is NewTagMaker)
      {
        newtag = (tagmaker as NewTagMaker).getTag
      }
       explorer.tagTableModel.tagLib.addTag(newtag)

    }
    explorer.tagTableModel.tagLib.write
    explorer.tagTableModel.update(explorer.tagTableModel.tagLib.tagLibFile)
    tageditor.tageditpane.removeAll
    tageditor.tageditpane.relayout
    explorer.tagTable.refreshAll
  }
}




