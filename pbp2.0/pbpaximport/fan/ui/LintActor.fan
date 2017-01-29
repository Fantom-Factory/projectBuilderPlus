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

    new make(ActorPool pool, ProjectBuilder projectBuilder,
        Button loadButton, Button importButton, Button closeButton, Label progressLabel, ProgressBar progressBar,
        |[Page:LintError[]]| onLintFunc) : super.make(pool, projectBuilder, loadButton, importButton, closeButton, progressLabel, progressBar)
    {
        Actor.locals[onLintFuncHandle] = onLintFunc
    }

    protected override Obj? doReceive([Str:Obj?] msgMap)
    {
        importDto := msgMap["importDto"] as ImportDto ?: throw Err("importDto not found in map $msgMap")
        lints := msgMap["lints"] as Type[]

        now := Duration.now

        progress(0, 0, "Running lints...")

        i := 0
        n := importDto.points.size

        index := [Page:LintError[]][:]

        importDto.points.each |point|
        {
            lintChecker := LintChecker(lints)
            lintChecker.checkLints(point)

            if (!lintChecker.results.isEmpty)
            {
                list := index[point.page]

                if (list == null)
                {
                    list = LintError[,]
                    index[point.page] = list
                }

                list.addAll(lintChecker.results)
            }

            progress(i, n, "Running lints...")
            i++
        }

        progress(1, 1, "Running lints done in ${(Duration.now - now).toLocale}")

        Desktop.callAsync |->|
        {
            onLintFunc := Actor.locals[onLintFuncHandle] as |[Page:LintError[]]|
            onLintFunc(index)
        }

        return null
    }
}
