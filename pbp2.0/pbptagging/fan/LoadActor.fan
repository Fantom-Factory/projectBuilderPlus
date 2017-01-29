/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using pbplogging

const class LoadActor : Actor
{
    private static const File baseDir := Env.cur.homeDir + `resources/tagging/`

    private const Str onFilesLoadedFuncHandle := Uuid().toStr

    private const ReloadActor reloadActor

    new make(ActorPool pool, |TaggingRow[]| onFilesLoadedFunc) : super.make(pool)
    {
        Actor.locals[onFilesLoadedFuncHandle] = onFilesLoadedFunc

        this.reloadActor = ReloadActor(pool, baseDir, this)
    }

    protected override Obj? receive(Obj? msg)
    {
        startReloadActor := msg as Bool ?: true // if not set START reload actor

        Logger.log.info("Loading tagging files from $baseDir")


        try
        {
            loadedRows := TaggingRow[,]

            if (baseDir.exists && baseDir.isDir)
            {
                baseDir.listFiles.findAll(|File file -> Bool| { file.ext == "txt" }).sort.each |file|
                {
                    loadedRows.addAll(createTaggingRow(file))
                }
            }

            Desktop.callAsync |->|
            {
                onFilesLoadedFunc := Actor.locals[onFilesLoadedFuncHandle] as |TaggingRow[]| ?: throw Err("Unable to find onFilesLoadedFuncHandle in Actor.locals")

                onFilesLoadedFunc(loadedRows)
            }

            if (startReloadActor)
            {
                Logger.log.info("Starting reload actor")
                reloadActor.sendLater(60sec, null)
            }
        }
        catch (Err e)
        {
            Logger.log.err("LoadActor error", e)
        }

        return null
    }

    private TaggingRow[] createTaggingRow(File file)
    {
        rows := TaggingRow[,]

        try
        {
            file.eachLine |Str line|
            {
                line = line.trim

                if (line.startsWith("**") || line.isEmpty)
                {
                    return
                }

                rows.add(TaggingRow(file, line.split(' ').findAll(|Str item -> Bool| { !item.isEmpty && !item[0].isSpace })))
            }
        }
        catch (IOErr e)
        {
            Logger.log.err("I/O error while loading tags from file $file", e)
            rows.clear
        }

        return rows
    }
}
