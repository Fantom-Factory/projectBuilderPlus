/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


using fwt
using pbpcore

class TagUtil
{
    // TODO method make static and class with private constructor
    Combo getTagLibCombo()
    {
        defTagLib := loadDefaultLib(FileUtil.getTagDir)

        combo := Combo
        {
            items = FileUtil.getSortedTagFiles
            onModify.add |e|
            {
                TagExplorer tagExp := e.widget.parent.parent
                tagExp.tagTableModel.update((e.widget as Combo).selected)
                tagExp.tagTable.refreshAll
            }
        }

        if (defTagLib != null) combo.selected = defTagLib

        return combo
    }

    static Bool saveDefaultLib(File libDir, File? defaultLib)
    {
      ok := defaultLib != null && defaultLib.exists && !defaultLib.isDir
      props := ["default": ok ? defaultLib.name : ""]
      libDir.plus(`tags.props`).writeProps(props)
      return ok
    }

    static File? loadDefaultLib(File libDir)
    {
      tagsFile := libDir.plus(`tags.props`)

      if (!tagsFile.exists || tagsFile.isDir)
      {
        saveDefaultLib(libDir, null)
      }

      fileName := tagsFile.readProps()["default"]

      libFile := libDir.plus(`$fileName`)

      if (libFile.exists && !libFile.isDir)
      {
        return libFile
      }
      else
      {
        // if not exists clear current lib file name
        saveDefaultLib(libDir, null)
        return null
      }
    }

}
