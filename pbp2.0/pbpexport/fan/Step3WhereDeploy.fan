/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder


class Step3WhereDeploy : ContentPane
{
    private ProjectBuilder projectBuilder
    private ExportModel exportModel

    private Button btnPushlet
    private Button btnHaystack

    new make(ProjectBuilder projectBuilder, ExportModel exportModel)
    {
        this.projectBuilder = projectBuilder
        this.exportModel = exportModel

        |Event| btnOnClick := |Event e|
        {
            exportModel.deployMode = ( e.widget == btnPushlet ? DeployMode.pushlet : (e.widget == btnHaystack ? DeployMode.haystack : null))
        }

        this.btnPushlet = Button() { text = "Pushlet"; mode = ButtonMode.radio; it.onAction.add(btnOnClick) }
        this.btnHaystack = Button() { text = "Haystack"; mode = ButtonMode.radio; it.onAction.add(btnOnClick) }

        this.content = EdgePane()
        {
            top = InsetPane(0, 0, 5, 0) { it.content = Label() { text = "Where to deploy?" } }
            center = InsetPane(20) { it.content = GridPane() { btnPushlet, btnHaystack, } }
        }

        content.relayout

        selectRadioButton
    }

    private Void selectRadioButton()
    {
        if (exportModel.deployMode == null)
        {
            btnPushlet.selected = false
            btnHaystack.selected = false
        }
        else if (exportModel.deployMode == DeployMode.pushlet)
            btnPushlet.selected = true
        else
            btnHaystack.selected = true
    }

}

enum class DeployMode
{
    pushlet("Pushlet"), haystack("Haystack")

    private new make(Str label) { this.label = label; }

    const Str label
}
