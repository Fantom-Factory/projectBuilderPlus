/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using [java] org.projecthaystack::HVal
using [java] org.projecthaystack::HRow
using [java] org.projecthaystack::HStr

/**
 * @author 
 * @version $Revision:$
 */
const class NavNode
{
    private const Unsafe navIdUnsafe
    HVal? navId() { navIdUnsafe.val as HVal }

    private const Unsafe disUnsafe
    HVal dis() { disUnsafe.val as HVal ?: HStr.make("n/a") }

    private const Unsafe rowUnsafe
    HRow row() { rowUnsafe.val as HRow ?: throw Err() }

    const NavNode[] children

    new make(HRow row, NavNode[] children)
    {
        this.rowUnsafe = Unsafe(row)
        this.navIdUnsafe = Unsafe(row.get("navId", false))
        this.disUnsafe = Unsafe(row.get("dis", false))
        this.children = children.toImmutable
    }

    new makeWithChildren(NavNode original, NavNode[] children)
    {
        this.rowUnsafe = Unsafe(original.row)
        this.navIdUnsafe = Unsafe(original.navId)
        this.disUnsafe = Unsafe(original.dis)
        this.children = children.toImmutable
    }

    override Bool equals(Obj? that)
    {
        x := that as NavNode

        if (x == null) return false

        return navId == x.navId &&
            dis == x.dis &&
            row == x.row &&
            children == x.children
    }

    override Int hash()
    {
        return row.hash.
            xor(navId == null ? 97 : navId.hash).
            xor(dis.hash).
            xor(children.hash)
    }

    override Str toStr() { "NavNode($navId, '$dis', $children)" }

    override Obj? trap(Str name, Obj?[]? args := null) { return row.get(name, false) }

}
