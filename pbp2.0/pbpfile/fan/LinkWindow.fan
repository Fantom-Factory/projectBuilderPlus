/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi
using pbpgui
using pbpcore

**
** UI to link file records to points
**
class LinkWindow : PbpWindow
{
  pbpcore::Point? selectedPoint := null
  //Obj? selectedPoint := null
  Project project
  FileMap fileMap

  private Table tblPoint  

  **
  ** Create window
  **
  new make(Window? window, Project project, FileMap fileMap) : super(window)
  {
    this.fileMap = fileMap
    this.project = project

    tblPoint = Table { model = RecTableModel(project.database.getClassMap(pbpcore::Point#), project) }

    title = "Link File Records -> Point"
    size = Size(720, 400)
    icon = PBPIcons.pbpIcon16
    mode = WindowMode.appModal
    content = InsetPane {
      insets = Insets(10)
      EdgePane {
        top = InsetPane{
          insets = Insets(0,0,10,0)
          Label {
            text = "Select point to which record \"${fileMap.dis}\" will be linked to"
            font = Font { bold = true }
          },
        }

        center = tblPoint

        bottom = GridPane {
          numCols = 1
          halignPane = Halign.right
          Button { text = "Link"; onAction.add { linkPoint } },
        }
      },
    }
  }

  private Void linkPoint()
  {
    selected := tblPoint.selected.first
    if (selected == null)
    {
      Dialog.openErr(this, "Please select a point to link to.")
      return;
    }

    // Copy file map info to point and vice versa
    Tag[] tags := [
      StrTag { name="fileMapName"; val=fileMap.dis },
      StrTag { name="fileQuery"; 
               val="ts=${fileMap.tsIndex},val=${fileMap.valIndex},discIdx=${fileMap.discriminatorIndex},discVal=${fileMap.discriminatorVal}" },
      DateTimeTag { name="fileLastTimeStamp"; val=null },
      DateTimeTag { name="fileLastSyncTime"; val=null }
    ]

    tags.push(StrTag{it.name="test"; val="test"})

    pbpcore::Point rec := (tblPoint.model as RecTableModel).getRow(selected)
    tags.each |tag|
    {
      rec = rec.add(tag)
    }
    project.database.save(rec)

    this.selectedPoint = rec
    this.close
  }
}
