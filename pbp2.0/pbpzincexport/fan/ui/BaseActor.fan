/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using gfx
using projectBuilder

abstract const class BaseActor : Actor
{
    protected const Str projectBuilderHandle := Uuid().toStr
    private const Str progressBarHandle := Uuid().toStr
    private const Str progressLabelHandle := Uuid().toStr
    private const Str exportButtonHandle := Uuid().toStr
    private const Str closeButtonHandle := Uuid().toStr

    private const Str exportButtonEnabledHandle := Uuid().toStr
    private const Str closeButtonEnabledHandle := Uuid().toStr

    new make(ActorPool pool, ProjectBuilder projectBuilder,
        Button exportButton, Button closeButton, Label progressLabel, ProgressBar progressBar) : super.make(pool)
    {
        // we must be in UI thread to work properly
        Actor.locals[projectBuilderHandle] = projectBuilder
        Actor.locals[progressBarHandle] = progressBar
        Actor.locals[progressLabelHandle] = progressLabel
        Actor.locals[exportButtonHandle] = exportButton
        Actor.locals[closeButtonHandle] = closeButton

        Actor.locals[exportButtonEnabledHandle] = exportButton.enabled
        Actor.locals[closeButtonEnabledHandle] = closeButton.enabled
    }

    protected abstract Obj? doReceive([Str:Obj?] msgMap)

    protected virtual Void onStart([Str:Obj?] msgMap)
    {
        enableButtons(false)
    }

    protected virtual Void onFinish([Str:Obj?] msgMap, Err? e)
    {
        enableButtons(true)
    }

    protected virtual Void onError([Str:Obj?] msgMap, Err e)
    {
        progress(0, 0, "Error occured")

        Desktop.callAsync |->|
        {
            Dialog.openErr(null, e.msg, e.traceToStr)
        }
    }

    protected override Obj? receive(Obj? msg)
    {
        msgMap := msg as Str:Obj? ?: throw Err("msg is not Str:Obj? but $msg")

        Err? err
        try
        {
            onStart(msgMap)

            return doReceive(msgMap)
        }
        catch (InterruptedErr e)
        {
            err = e
            // this will happen when ActorPool is killed

            return null
        }
        catch (Err e)
        {
            Pod.of(this).log.err("Error while running actor", e)

            onError(msgMap, e)

            err = e

            return null
        }
        finally
        {
            onFinish(msgMap, err)
        }
    }

    protected Void progress(Int cur, Int count, Str message)
    {
        Desktop.callAsync |->|
        {
            progressLabel := (Actor.locals[progressLabelHandle] as Label)
            progressLabel.text = message
            progressLabel.parent.relayout

            progressBar := (Actor.locals[progressBarHandle] as ProgressBar)
            progressBar.min = 0
            progressBar.max = count
            progressBar.val = cur
        }
    }

    protected Void enableButtons(Bool enabled)
    {
        Desktop.callAsync |->|
        {
            if (enabled)
            {
                (Actor.locals[exportButtonHandle] as Button).enabled = Actor.locals[exportButtonEnabledHandle] as Bool ?: throw Err("Unable to find saved button's Bool state")
                (Actor.locals[closeButtonHandle] as Button).enabled = Actor.locals[closeButtonEnabledHandle] as Bool ?: throw Err("Unable to find saved button's Bool state")
            }
            else
            {
                (Actor.locals[exportButtonHandle] as Button).enabled = false
                (Actor.locals[closeButtonHandle] as Button).enabled = false
            }
        }
    }

    protected Void enableExportButton(Bool enabled)
    {
        Desktop.callAsync |->|
        {
            if (enabled)
            {
                (Actor.locals[exportButtonHandle] as Button).enabled = Actor.locals[exportButtonEnabledHandle] as Bool ?: throw Err("Unable to find saved button's Bool state")
            }
            else
            {
                (Actor.locals[exportButtonHandle] as Button).enabled = false
            }
        }
    }

}
