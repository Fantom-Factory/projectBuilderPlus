/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

final class FunctionSortModel
{
    internal static const Log log := FunctionSortModel#.pod.log

    internal File folder
    internal File[] files := File[,]
    internal File sortConfig

    new make(File folder)
    {
        if (!folder.isDir)
        {
            throw Err("Specified folder $folder should be directory")
        }

        this.folder = folder

        this.sortConfig = folder + `sort.config`
    }

    File[] getFunctionList()
    {
        return files
    }

    Bool moveFunctionUp(File functionFile)
    {
        fileIndex := files.index(functionFile)
        if (fileIndex == null || fileIndex - 1 < 0 )
        {
            return false
        }

        swapIndex := fileIndex - 1;

        files.swap(fileIndex, swapIndex)

        return true
    }

    Bool moveFunctionDown(File functionFile)
    {
        fileIndex := files.index(functionFile)
        if (fileIndex == null || fileIndex + 1 >= files.size )
        {
            return false
        }

        swapIndex := fileIndex + 1;

        files.swap(fileIndex, swapIndex)

        return true
    }

    Void load()
    {
        files := folder.listFiles.findAll |File file -> Bool| { file.ext == "dfunc" }
        this.files = sortFiles(folder, files, sortConfig)
    }

    internal static File[] sortFiles(File folder, File[] files, File sortConfig)
    {
        File[] filesSort := files.dup
        if (sortConfig.exists)
        {
            // we have sort configuration, try to load it or delete invalid configuration
            Uri[]? readUris := null
            try
            {
                readUris = sortConfig.readObj as Uri[]
            }
            catch(IOErr e)
            {
                log.debug("Sort config not in proper format.", e)
            }

            if (readUris == null)
            {
                sortConfig.delete

                readUris = Uri[,]
            }

            filesSort = readUris.reduce(File[,]) |File[] reduction, Uri uri -> File[]| { reduction.add(folder + uri) }
        }

        filesInSortConfig := filesSort.intersection(files)
        filesNotInSortConfig := removeAll(files, filesInSortConfig)

        return File[,].addAll(filesInSortConfig).addAll(filesNotInSortConfig.sort)
    }

    private static File[] removeAll(File[] files, File[] filesToRemove)
    {
        result := files.dup

        filesToRemove.each |file|
        {
            result.remove(file)
        }

        return result
    }

    Void save()
    {
        sortConfig.writeObj(urisToSave(files))
    }

    internal static Uri[] urisToSave(File[] files)
    {
        return files.map |File file -> Uri| { file.uri.name.toUri }
    }
}
