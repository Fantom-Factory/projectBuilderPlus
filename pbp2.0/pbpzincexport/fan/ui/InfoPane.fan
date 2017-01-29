/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpgui
using pbpcore
using pbpobix

class InfoPane : EdgePane
{
    private ProjectBuilder projectBuilder
    private Button exportButton

    private Table recordTable
    RecordTableModel? recordTableModel { set { &recordTableModel = it; recordTable.model = it; recordTable.refreshAll; lintText.text = "";} }

    private Text lintText
    ProgressBar progressBar { private set }
    Label progressLabel { private set }

    new make(ProjectBuilder projectBuilder, Button exportBtn) : super.make()
    {
        this.projectBuilder = projectBuilder
        this.exportButton = exportBtn

        this.recordTable = Table()
        {
            it.multi = false
            it.onSelect.add |event| { showLintOnRowSelect(event) }
        }

        this.lintText = Text() { it.multiLine = true; it.editable = false;  }

        this.progressBar = ProgressBar()

        this.progressLabel = Label() { it.text = "" }


        this.center = InsetPane(12, 12, 0, 12)
        {
            it.content = EdgePane()
            {
                it.center = InsetPane() { it.content = createRecordTablePane() }
            }
        }

        this.bottom = InsetPane(12, 12, 0, 12)
        {
            it.content = EdgePane()
            {
                it.left = progressLabel
                it.center = progressBar
            }
        }

        relayout
    }

    private Void showLintOnRowSelect(Event event)
    {
        recordTableModel := recordTable.model as RecordTableModel
        lintMessage := ""
        if (recordTableModel.lintErrorIndex != null && event.index != null)
        {
            recordId := recordTableModel.text(0, event.index)
            lintErrors := recordTableModel.lintErrorIndex[recordId]

            if (lintErrors != null)
            {
                sb := StrBuf()
                lintErrors.each |lintError|
                {
                    sb.add(lintError.message).add("\n")
                }
                lintMessage = sb.toStr
            }
        }

        lintText.text = lintMessage
    }


    private SashPane createRecordTablePane()
    {
        return SashPane()
        {
            it.weights = [80,20]
            recordTable,
            createLintPage(),
        }
    }

    private EdgePane createLintPage()
    {
        return EdgePane()
        {
            it.top = BorderPane()
            {
                it.border = Border("1,1,0,1")
                it.content = Label() { it.text = "Lint details"; it.halign = Halign.center }
            }
            it.center = lintText
        }
    }

}
