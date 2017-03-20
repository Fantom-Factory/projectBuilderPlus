/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt

/**
 * @author 
 * @version $Revision:$
 */
const class ReconnectActor : Actor
{
    private const Str funcKey := Uuid().toStr
    private const HaystackConnection[] conns
    private const Bool checked

    new make(ActorPool pool, HaystackConnection[] conns, Bool checked, |HaystackConnection[], [Str:Err]| onFinishFunc) : super.make(pool)
    {
        this.conns = conns
        this.checked = checked

        Actor.locals[funcKey] = onFinishFunc
    }

    protected override Obj? receive(Obj? msg)
    {
        try
        {
            Desktop.callAsync |->|
            {
                onHaystackManagerActionFunc := Actor.locals[HaystackManager.onHaystackManagerActionFuncKey] as |Str, Obj?| ?: throw Err()
                onHaystackManagerActionFunc("connStart", null)
            }

            connErrors := Str:Err[:]
            conns.each |conn|
            {
                try
                {
                    result := Actor(pool()) |Obj? msg2 -> Obj?|
                    {
                        Err? err := null
                        try
                        {
                            conn.reconnect(checked)
                        }
                        catch (Err e)
                        {
                            err = e
                        }

                        return err
                    }.send(null).get((checked ? 30sec : 5sec))

                    if (result is Err)
                    {
                        connErrors[conn.name] = (Err)result
                    }
                }
                catch (Err e)
                {
                    connErrors[conn.name] = e
                }
            }

            Desktop.callAsync |->|
            {
                (Actor.locals[funcKey] as |HaystackConnection[], [Str:Err]| ?: throw Err())(conns, connErrors)
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
                onHaystackManagerActionFunc("connEnd", null)
            }
        }
    }
}
