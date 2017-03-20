/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

facet class ToolbarExt
{
    const Str[] toolbarIds

    static Void initToolbarExts(Str:ToolbarCommandAdder toolbarCommandAdderMap, Obj[] ctorParams)
    {
        Pod[] toolbarPods := Pod.list.findAll |Pod pod -> Bool| { pod.meta.containsKey("pbpToolbarExt") }
        toolbarPods.each |pod|
        {
            types := pod.types.findAll |Type type -> Bool| { type.fits(Command#) && type.hasFacet(ToolbarExt#) }

            types.each |type|
            {
                ToolbarExt facet := type.facet(ToolbarExt#)
                facet.toolbarIds.each |id|
                {
                    if (toolbarCommandAdderMap[id] != null)
                    {
                        toolbarCommandAdderMap[id].addCommand(id, type.make([,].add(id).addAll(ctorParams)))
                    }
                }
            }
        }
    }
}

mixin ToolbarCommandAdder
{
    abstract Void addCommand(Str toolbarId, Command command)
}

