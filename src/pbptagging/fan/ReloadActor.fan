/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbplogging

const class ReloadActor : Actor
{
    private const File baseDir
    private const LoadActor loadActor

    new make(ActorPool pool, File baseDir, LoadActor loadActor) : super.make(pool)
    {
        this.baseDir = baseDir
        this.loadActor = loadActor
    }

    protected override Obj? receive(Obj? msg)
    {
        oldFiles := msg as File[] ?: File[,]

        Logger.log.info("Reload check with $oldFiles.size old files")

        newFiles := File[,]

        try
        {
            if (baseDir.exists && baseDir.isDir)
            {
                newFiles = baseDir.listFiles.findAll(|File file -> Bool| { file.ext == "txt" }).sort
            }

            if (reload(oldFiles, newFiles))
            {
                Logger.log.info("Reloading")
                loadActor.send(false /* do not start reloadActor */)
            }

            sendLater(60sec, newFiles.toImmutable)
            return null
        }
        catch (Err e)
        {
            Logger.log.err("ReloadActor error", e)
            return null
        }
    }

    private Bool reload(File[] oldFiles, File[] newFiles)
    {
        intersection := oldFiles.intersection(newFiles)
        if (intersection != newFiles || intersection != oldFiles)
        {
            return true
        }

        reload := false

        newFiles.eachWhile |newFile|
        {
            oldFile := oldFiles.find |file -> Bool| { file == newFile }

            if (newFile.modified != newFile.modified)
            {
                reload = true
                return newFile
            }

            return null // continue
        }

        return reload
    }
}
