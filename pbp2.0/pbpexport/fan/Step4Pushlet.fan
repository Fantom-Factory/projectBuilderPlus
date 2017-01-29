/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder

class Step4Pushlet : ContentPane
{
    private ProjectBuilder projectBuilder
    private ExportModel exportModel
    private Text summary

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

        this.content = EdgePane()
        {
            it.top = InsetPane(0, 0, 5, 0) { it.content = Label() { text = "Export ${exportModel.deployMode.label} settings" } }
            it.center = InsetPane(5) { it.content = summary }
        }

        summary.text = ExportUtils.generateExportSummary(exportModel)

        relayout
    }

}
