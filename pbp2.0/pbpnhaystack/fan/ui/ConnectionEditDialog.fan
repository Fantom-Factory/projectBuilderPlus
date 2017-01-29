/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui

/**
 * @author 
 * @version $Revision:$
 */
class ConnectionEditDialog : PbpWindow
{
    private static const Color invalidColor := Color.red

    private Text txtName
    private Text txtUri
    private Text txtUsername
    private Text txtPassword

    private Button btnApply
    private Button btnCancel

    private Bool apply

    new make(Window parent, Str name, Str uri, Str username, Str password) : super(parent)
    {
        this.mode = WindowMode.appModal

        this.txtName = Text() { it.text = name }
        this.txtUri = Text() { it.text = uri; it.onKeyUp.add |Event e| { validateUri(e) } }
        this.txtUsername = Text() { it.text = username }
        this.txtPassword = Text() { it.text = password; it.password = true }

        this.apply = false

        this.btnApply = Button.makeCommand(Command("Apply", null, |Event event| { apply = true; close() }))
        this.btnCancel = Button.makeCommand(Command("Cancel", null, |Event event| { close() }))

        this.content = InsetPane() { it.content = GridPane()
        {
            it.numCols = 2
            Label() { it.text = "Name" }, txtName,
            Label() { it.text = "Uri" }, txtUri,
            Label() { it.text = "Username" }, txtUsername,
            Label() { it.text = "Password" }, txtPassword,
            Label(), GridPane() { it.numCols = 2; btnApply, btnCancel, }
        } }
    }

    private Void validateUri(Event event)
    {
        if (event.widget is Text)
        {
            txt := event.widget as Text
            txt.bg = (Uri.fromStr(txt.text, false) == null) ? invalidColor : null
        }
    }

    override Obj? open()
    {
        super.open()

        if (apply)
        {
            return ["name": txtName.text, "uri": txtUri.text, "username": txtUsername.text, "password": txtPassword.text]
        }
        else
        {
            return null
        }

    }


}
