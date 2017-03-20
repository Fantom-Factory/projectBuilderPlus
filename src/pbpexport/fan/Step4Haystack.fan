/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder

class Step4Haystack : ContentPane
{
    private ProjectBuilder projectBuilder
    private ExportModel exportModel
    private Text summary
    private Text editIp
    private Text editName
    private Text editPassword

    new make(ProjectBuilder projectBuilder, ExportModel exportModel)
    {
        this.projectBuilder = projectBuilder
        this.exportModel = exportModel

        this.summary = Text()
        {
            it.editable = false
            it.multiLine = true
            it.wrap = true
            it.hscroll = false
            it.vscroll = true
            it.font = Desktop.sysFontMonospace
        }

        testConnectionPane := EdgePane()
        {
            it.left = Button() { it.text = "Check"}
            it.center = Text()
            {
                it.prefRows = 4
                it.editable = false
                it.multiLine = true
                it.font = Desktop.sysFontMonospace
            }
        }

        this.editIp = Text() { prefCols = 10 }
        this.editName = Text() { prefCols = 10 }
        this.editPassword = Text() { password = true; prefCols = 10 }

        configConnectionPane := GridPane()
        {
            it.numCols = 4
            Label(),
            Label() { it.text = "Router IP"},
            Label() { it.text = "Name"},
            Label() { it.text = "Password"},
            // new row
            Label() { it.text = "Haystack"},
            editIp,
            editName,
            editPassword,
        }

        this.content = EdgePane()
        {
            it.top = InsetPane(0, 0, 5, 0) { it.content = Label() { text = "Export ${exportModel.deployMode.label} settings" } }
            it.center = InsetPane(5) { it.content = summary }
            it.bottom = InsetPane(0, 0, 5, 0) { it.content = EdgePane()
            {
                it.top = InsetPane(5) { it.content = configConnectionPane }
                it.bottom = InsetPane(5) { it.content = testConnectionPane }
            } }
        }

        summary.text = ExportUtils.generateExportSummary(exportModel)

        relayout
    }

}
