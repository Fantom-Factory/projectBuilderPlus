/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent

/**
 * @author 
 * @version $Revision:$
 */
const class PoolKillActor : Actor
{
    private const AtomicBool kill

    new make(ActorPool pool) : super.make(pool)
    {
        this.kill = AtomicBool(false)
    }

    protected override Obj? receive(Obj? msg)
    {
        result := null

        switch ("$msg")
        {
            case "killed":
                result = kill.val
            case "kill":
                kill.getAndSet(true)
            default:
                sendLater(1000ms, null);
        }
        return result
    }
}
