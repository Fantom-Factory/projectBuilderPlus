/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi

/**
 * @author 
 * @version $Revision:$
 */

class NavNodeTreeModel : TreeModel
{
    private NavNode[] navNodeRoots

    new make(NavNode[] navNodeRoots)
    {
        this.navNodeRoots = navNodeRoots
    }

    override Obj[] roots() { navNodeRoots }

    override Str text(Obj node)
    {
        return (node as NavNode)?.dis?.toString ?: ""
    }

    override Image? image(Obj node)
    {
        isSite := (node as NavNode)?->site != null
        isEquip := (node as NavNode)?->equip != null
        isPoint := (node as NavNode)?->point != null

        if (isSite) { return PBPIcons.site }
        if (isEquip) { return PBPIcons.equip }
        if (isPoint) { return PBPIcons.point }


        return null
    }

    override Obj[] children(Obj node)
    {
        return (node as NavNode)?.children ?: Obj#.emptyList
    }

}
