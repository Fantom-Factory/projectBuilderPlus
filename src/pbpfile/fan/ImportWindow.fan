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

**
** Wizard dialog to locate and import file
**
class ImportWindow : PbpWindow
{
  private Str:Str formats := Str:Str[:]

  **
  ** Create window
  **
  new make(Window? window) : super(window)
  {
    title = "Import File"
    size = Size(720, 400)
    icon = PBPIcons.pbpIcon16
    mode = WindowMode.appModal
    content = InsetPane {
      insets = Insets(10)
      paneSelectFile,
    }

    formats.ordered = true
    formats.add("csv"   , "CSV (Comma Separated Values)")
    formats.add("tabsep", "Tab Separated Values")
    cmbFormat.items = formats.vals
  }

  **
  ** Create window for edit mode. Will show fileMap selection page only.
  **
  new makeForEdit(Window? window, PbpFileConn conn) : this.make(window)
  {
    txtFilePath.text = conn.uri.toFile.toStr
    gotoSelectValue(false)

    conn.fileMaps.each |fileMap| {
      input := addFileMapInput
      input.setFileMap(fileMap)
    }
    btnBack.visible = false
  }

  private Text txtFilePath := Text()
  private Button btnBack := Button { text = "< Back"; onAction.add { gotoSelectFile } }
  private Combo cmbFormat := Combo()

  private Uri fileUri()
  {
    return txtFilePath.text.toUri
  }
  
  private Pane paneSelectFile := EdgePane {
    top = makeTitle("Select a file that contain the data")
    center = GridPane {
      numCols = 3

      Label { text = "File format" },
      cmbFormat,
      Label { text = ""},

      Label { text = "Select file " },
      txtFilePath,
      Button { text = "Browse..."; onAction.add { browseFile } },
    }
    bottom = makeButtons([
      Button { text = "Next >"; onAction.add { gotoSelectValue } }
    ])
  }

  private Table tblCsv := Table {
    it.size = Size(100, 100)
  }

  private Pane paneFileMapContainer := GridPane()

  private Pane paneSelectValue := EdgePane {
    top = makeTitle("Identify timestamp-value records")
    center = SashPane {
      orientation = Orientation.vertical
      tblCsv,
      ScrollPane {
        GridPane {
          paneFileMapContainer,
          ContentPane {
            Button {
              text = "Add more record..."
              image = Image(`fan://pbpi/res/img/projectTabAdd16.png`)
              onAction.add { addFileMapInput }
            },
          },
        },
      },
    }
    bottom = makeButtons([
      btnBack,
      Button { text = "Import"; onAction.add { import } }
    ])
  }

  private FileMapInput addFileMapInput(Bool closable := true)
  {
    c := paneFileMapContainer

    selectedTsCol := (c.children.getSafe(0) as FileMapInput)?.tsName
    input := FileMapInput(cols, selectedTsCol ?: "", closable)
    input.onClose.add |e| { c.remove(e.widget); relayoutFileMapContainer }
    c.add(input)

    relayoutFileMapContainer

    return input
  }

  private Void relayoutFileMapContainer()
  {
    c := paneFileMapContainer
    c.relayout
    c.parent.relayout
    c.parent.parent.relayout
  }

  private Pane makeTitle(Str title)
  {
    return InsetPane {
      insets = Insets(0,0,10,0)
      Label {
        text = title
        font = Font { bold = true }
      },
    }
  }

  private Pane makeButtons(Button[] buttons)
  {
    pane := GridPane {
      halignPane = Halign.right
      numCols = buttons.size
    }
    buttons.each { pane.add(it) }
    return pane
  }

  private Void browseFile()
  {
    file := FileDialog().open(this)
    if (file != null)
      txtFilePath.text = file.toStr
  }

  Str[] cols := [,]
  CsvTableModel? csvTableModel := null

  private Void gotoSelectValue(Bool addEmptyFileMapInput := true)
  {
    if (txtFilePath.text.trim == "")
    {
      Dialog.openErr(this, "Please select a file to proceed.")
      return;
    }

    // Read file and populate table
    csvTableModel = CsvTableModel(fileUri.toFile.in)
    cols = csvTableModel.headers

    tblCsv.model = csvTableModel

    paneFileMapContainer.removeAll
    if (addEmptyFileMapInput)
      paneFileMapContainer.add(FileMapInput(cols, "", false))

    activatePane(paneSelectValue)
  }

  private Void gotoSelectFile()
  {
    yesNo := Dialog.openQuestion(this,
                             "This will remove all timestamp-value records that you've specified.\n
                              Are you sure to go back?",
                             Dialog.yesNo)
    if (yesNo == Dialog.yes)
    {
      activatePane(paneSelectFile)
    }
  }

  private FileMap[] fileMaps := FileMap[,]

  private Void import()
  {
    error := false
    fileMaps = FileMap[,]

    paneFileMapContainer.children
      .findAll { it is FileMapInput }
      .each |FileMapInput input| {

        fileMap := input.getFileMap(fileUri)

        // Validate input
        if (fileMap.dis == "")
        {
          Dialog.openErr(this, "You must specify all fileMap names.")
          error = true
        }

        if (fileMap.tsIndex == fileMap.valIndex)
        {
          Dialog.openErr(this,
            "Cannot use the same column '${fileMap.tsName}' for timestamp and value for fileMap named '${fileMap.dis}'")
          error = true
        }

        if (fileMap.hasDiscriminator && fileMap.discriminatorVal == "")
        {
          Dialog.openErr(this,
            "If you specify a discriminator column, you should also specify the discriminator value (discriminator = ?)")
          error = true
        }

        fileMaps.add(fileMap)
      }

    if (!error && fileMaps.size == 0)
    {
      Dialog.openErr(this,
        "You must have at least 1 file map selected.")
      error = true
    }    

    if (!error)
      this.close
  }

  PbpFileConn? getConn()
  {
    return (fileMaps.size > 0) ? PbpFileConn(fileUri, formats.keys[cmbFormat.selectedIndex], fileMaps) : null
  }

  private Void activatePane(Pane pane)
  {
    container := (ContentPane)this.content
    container.content = pane
    container.relayout
    pane.relayout
  }
}
