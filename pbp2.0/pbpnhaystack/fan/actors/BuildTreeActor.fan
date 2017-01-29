/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using [java] org.projecthaystack.client::HClient
using [java] org.projecthaystack::HGrid
using [java] org.projecthaystack::HGridBuilder
using [java] org.projecthaystack::HDictBuilder

/**
 * @author 
 * @version $Revision:$
 */
const class BuildTreeActor : Actor
{
    private const HaystackConnection conn
    private const Str funcKey
    private const NavNode? selNavNode
    private const Bool recursive
    private const Bool fetchAxAnnotatedOnly

    new make(ActorPool pool, HaystackConnection conn, |NavNode[]| onResultFunc, NavNode? selNavNode, Bool recursive, Bool fetchAxAnnotatedOnly) : super.make(pool)
    {
        this.conn = conn
        this.selNavNode = selNavNode
        this.recursive = recursive
        this.funcKey = Uuid().toStr
        this.fetchAxAnnotatedOnly = fetchAxAnnotatedOnly
        Actor.locals[funcKey] = onResultFunc
    }

    protected override Obj? receive(Obj? msg)
    {
        curKillActor := msg as PoolKillActor ?: throw Err()

        try
        {
            Desktop.callAsync |->|
            {
                onHaystackManagerActionFunc := Actor.locals[HaystackManager.onHaystackManagerActionFuncKey] as |Str, Obj?| ?: throw Err()
                onHaystackManagerActionFunc("treeStart", null)
            }

            result := fetchTree(curKillActor, conn.hClient, (selNavNode != null ? selNavNode.navId.toStr : "sep:/"), recursive, fetchAxAnnotatedOnly).toImmutable

            Desktop.callAsync |->|
            {
                (Actor.locals[funcKey] as |NavNode[]| ?: throw Err())(result)
                Actor.locals[funcKey] = null
            }

            return null
        }
        catch (Err e)
        {
            e.trace
            throw e
        }
        finally
        {
            Desktop.callAsync |->|
            {
                onHaystackManagerActionFunc := Actor.locals[HaystackManager.onHaystackManagerActionFuncKey] as |Str, Obj?| ?: throw Err()
                onHaystackManagerActionFunc("treeEnd", null)
            }
        }
    }

    private static Void checkKilled(PoolKillActor killActor)
    {
        killed := null
        try
        {
            killed = killActor.send("killed").get
        }
        catch (Err e)
        {
            throw Err("Poll is killed", e)
        }

        if (killed == true)
        {
            throw Err("Poll is killed")
        }
    }

    private static NavNode[] fetchTree(PoolKillActor killActor, HClient hClient, Str currNavId, Bool recursive, Bool fetchAxAnnotatedOnly := false)
    {
        checkKilled(killActor)

        grid := nav(hClient, currNavId)

        result := NavNode[,]

        for (i := 0; i < grid.numRows; ++i)
        {
            row := grid.row(i)
            if(fetchAxAnnotatedOnly && row.missing("axAnnotated") && row.has("point")) { continue }
            navId := row.get("navId", false)
            result.add(NavNode(row, navId != null && recursive ? fetchTree(killActor, hClient, "$navId", recursive, fetchAxAnnotatedOnly) : NavNode[,]))
        }

        return result
    }

    private static HGrid nav(HClient hClient, Str? navId := null)
    {
        req := (navId != null ? HGridBuilder.dictToGrid(HDictBuilder().add("navId", navId).toDict) : HGrid.EMPTY)
        return hClient.call("nav", req)
    }
}
