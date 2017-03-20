/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

facet class MenuExt
{
    const Str menuId
    const Int weight := 0

    internal static Void initMenuExts(Menu fileMenu, Menu toolsMenu, Menu helpMenu, Obj[]? ctorParams)
    {
        Pod[] menuPods := Pod.list.findAll |Pod pod -> Bool| { pod.meta.containsKey("pbpMenuExt") }
        menuPods.each |pod|
        {
            hasFileMenuExtItems := false
            hasToolsMenuExtItems := false
            hasHelpMenuExtItems := false

            types := pod.types.findAll |Type type -> Bool| { type.fits(Command#) && type.hasFacet(MenuExt#) }

            types.sort |Type a, Type b->Int| { return a.facet(MenuExt#)->weight <=> b.facet(MenuExt#)->weight }

            types.each |type|
            {
                MenuExt facet := type.facet(MenuExt#)
                switch(facet.menuId)
                {
                    case "file":
                        if (!hasFileMenuExtItems) { fileMenu.addSep }
                        hasFileMenuExtItems = true
                        fileMenu.addCommand(type.make(ctorParams))
                    case "tools":
                        if (!hasToolsMenuExtItems) { toolsMenu.addSep }
                        hasToolsMenuExtItems = true
                        toolsMenu.addCommand(type.make(ctorParams))
                    case "help":
                    if (!hasHelpMenuExtItems) { helpMenu.addSep }
                        hasHelpMenuExtItems = true
                        helpMenu.addCommand(type.make(ctorParams))
                }
            }
         }
    }
}

