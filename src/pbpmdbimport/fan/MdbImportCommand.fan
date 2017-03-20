/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder

@MenuExt{ menuId = "tools"; weight = 100 }
class MdbImportCommand : Command
{
    private ProjectBuilder projectBuilder

    new make(ProjectBuilder projectBuilder) : super.makeLocale(MdbImportCommand#.pod, "mdbImportCommand")
    {
        this.projectBuilder = projectBuilder
    }

    protected override Void invoked(Event? event)
    {
        if (projectBuilder.currentProject != null)
        {
            MdbImportWindow(projectBuilder).open()
        }
        else
        {
            Dialog.openErr(projectBuilder.builder, "Can not import from MS Access db", "Please select project before import from MS Access db")
        }
    }
}
