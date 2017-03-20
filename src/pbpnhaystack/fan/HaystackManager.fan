/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using projectBuilder

/**
 * @author 
 * @version $Revision:$
 */

class HaystackManager
{
    internal static const Str onHaystackManagerActionFuncKey := Uuid().toStr
    private ActorPool? actorPool
    private PoolKillActor? killActor

    new make(|Str action, Obj? args| onHaystackManagerActionFunc)
    {
        startActorPool()
        Actor.locals[onHaystackManagerActionFuncKey] = onHaystackManagerActionFunc
    }

    Void startActorPool()
    {
        if (actorPool != null) { stopActorPool() }

        this.actorPool = ActorPool()
        this.killActor = PoolKillActor(actorPool)
        this.killActor.send(null)
    }

    Void stopActorPool()
    {
        if (actorPool != null)
        {
            killActor.send("kill")
            actorPool.kill;
            actorPool = null
        }
    }

    Void reconnect(HaystackConnection[] conns, Bool checked, |HaystackConnection[], [Str:Err]| onFinishFunc)
    {
        ReconnectActor(actorPool, conns, checked, onFinishFunc).send(null)
    }

    Void buildTree(HaystackConnection conn, Bool recursive, |NavNode[]| onResultFunc, NavNode? selNavNode := null, Bool fetchAxAnnotatedOnly := false)
    {
        BuildTreeActor(actorPool, conn, onResultFunc, selNavNode, recursive, fetchAxAnnotatedOnly).send(killActor)
    }

    Void mapping(Mapping[] mapping, Window parent, Int connIdx, ProjectBuilder projectBuilder,
            |Int -> HaystackConnection| supplyConnFunc,
            |Int, HaystackConnection| updateConnFunc,
            |Err?| onFinishFunc)
    {
        MappingActor(mapping,
            actorPool,
            connIdx,
            projectBuilder,
            MappingProgressWindow(parent, mapping.size),
            supplyConnFunc,
            updateConnFunc,
            onFinishFunc).send(null)
    }

    Void sep(NavNode[] siteNodes, Window parent, Int connIdx, ProjectBuilder projectBuilder,
                |Int -> HaystackConnection?| supplyConnFunc,
                |Int, HaystackConnection| updateConnFunc,
                |Err?| onFinishFunc)
    {
        ImportSepActor(siteNodes,
            actorPool,
            connIdx,
            projectBuilder,
            MappingProgressWindow(parent, siteNodes.size),
            supplyConnFunc,
            updateConnFunc,
            onFinishFunc).send(null)

    }
}
