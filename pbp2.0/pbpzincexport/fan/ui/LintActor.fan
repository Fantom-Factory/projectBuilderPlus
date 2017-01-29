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

const class LintActor : BaseActor
{


    private const Str onLintFuncHandle := Uuid().toStr

    private const Type[] lints


    new make(ActorPool pool, ProjectBuilder projectBuilder,
        Button exportButton, Button closeButton, Label progressLabel, ProgressBar progressBar,
        Type[] lints, |[Str:LintError[]]| onLintFunc) : super.make(pool, projectBuilder, exportButton, closeButton, progressLabel, progressBar)
    {
        this.lints = lints
        Actor.locals[onLintFuncHandle] = onLintFunc
    }

    protected override Obj? doReceive([Str:Obj?] msgMap)
    {
        nodesToCheck := msgMap["nodesToCheck"] as RecordTreeDto[] ?: throw Err("nodes not found in map $msgMap")

        now := Duration.now

        progress(0, 0, "Running lints...")

        i := 0
        n := nodesToCheck.size

        index := [Str:LintError[]][:]

        nodesToCheck.each |node|
        {
            nodeId := node.record.id.toStr
            lintChecker := LintChecker(lints)
            lintChecker.checkLints(node)

            if (!lintChecker.results.isEmpty)
            {
                list := index[nodeId]

                if (list == null)
                {
                    list = LintError[,]
                    index[nodeId] = list
                }

                list.addAll(lintChecker.results)
            }

            progress(i, n, "Running lints...")
            i++
        }

        progress(1, 1, "Running lints done in ${(Duration.now - now).toLocale}")

        Desktop.callAsync |->|
        {
            onLintFunc := Actor.locals[onLintFuncHandle] as |[Str:LintError[]]|
            if(index.size > 0)
                enableExportButton(false)
            else
                enableExportButton(true)

            onLintFunc(index)
        }

        return null
    }

}
