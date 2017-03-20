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
class AxImportCommand : Command
{
    private ProjectBuilder projectBuilder

    new make(ProjectBuilder projectBuilder) : super.makeLocale(AxImportCommand#.pod, "axImportCommand")
    {
        this.projectBuilder = projectBuilder
    }

    protected override Void invoked(Event? event)
    {
//        try {
        if (projectBuilder.currentProject != null)
        {
            AxImportWindow(projectBuilder).open()
        }
        else
        {
            Dialog.openErr(projectBuilder.builder, "Can not import from Niagara", "Please select project before import from Niagara")
        }
//        } catch (Err e)
//        {
//            e.trace(Env.cur.out, ["maxDepth": 500])
//        }
    }
}
