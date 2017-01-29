/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


class FunctionSortModelTest : Test
{
    internal static const Log log := FunctionSortModel#.pod.log

    File sortConfig := File.createTemp
    File folder := sortConfig.parent

    override Void setup()
    {
        log.info("folder $folder")
        log.info("sortConfig $sortConfig")
    }

    override Void teardown()
    {
        sortConfig.delete
    }

    Void testSortFiles_empty()
    {
        files := File[,]

        FunctionSortModel.sortFiles(folder, files, sortConfig)

        verifyEq(0, files.size)
        verifyEq(false, sortConfig.exists)
    }

    Void testSortFiles_files2_sort0()
    {
        files := File[folder + `file2`, folder + `file1`]

        res := FunctionSortModel.sortFiles(folder, files, sortConfig)

        verifyEq(2, res.size)
        verifyEq(folder + `file1`, res[0])
        verifyEq(folder + `file2`, res[1])
        verifyEq(false, sortConfig.exists)
    }

    Void testSortFiles_files2_sort2_valid()
    {
        files := File[folder + `file1`, folder + `file2`]
        sortConfig.writeObj([`file2`, `file1`])

        res := FunctionSortModel.sortFiles(folder, files, sortConfig)

        verifyEq(2, res.size)
        verifyEq(folder + `file2`, res[0])
        verifyEq(folder + `file1`, res[1])
        verifyEq(true, sortConfig.exists)
    }

    Void testSortFiles_files3_sort3_lessSort()
    {
        files := File[folder + `file1`, folder + `file3`, folder + `file2`]
        sortConfig.writeObj([`file3`, `file1`])

        res := FunctionSortModel.sortFiles(folder, files, sortConfig)

        verifyEq(3, res.size)
        verifyEq(folder + `file3`, res[0])
        verifyEq(folder + `file1`, res[1])
        verifyEq(folder + `file2`, res[2])
        verifyEq(true, sortConfig.exists)
    }

    Void testSortFiles_files2_sort3()
    {
        files := File[folder + `file1`, folder + `file3`]
        sortConfig.writeObj([`file3`, `file1`])

        res := FunctionSortModel.sortFiles(folder, files, sortConfig)

        verifyEq(2, res.size)
        verifyEq(folder + `file3`, res[0])
        verifyEq(folder + `file1`, res[1])
        verifyEq(true, sortConfig.exists)
    }

    Void testSortFiles_files2_sort3_notInSortList()
    {
        files := File[folder + `file1`, folder + `file3`, folder + `file5`, folder + `file4`]
        sortConfig.writeObj([`file3`, `file1`])

        res := FunctionSortModel.sortFiles(folder, files, sortConfig)

        verifyEq(4, res.size)
        verifyEq(folder + `file3`, res[0])
        verifyEq(folder + `file1`, res[1])
        verifyEq(folder + `file4`, res[2])
        verifyEq(folder + `file5`, res[3])
        verifyEq(true, sortConfig.exists)
    }

    // ------------------------------------------------------

    Void testUrisToSave()
    {
        Uri[] uris := FunctionSortModel.urisToSave(File[folder + `file1.txt`, folder + `file3.png`, folder + `file5.xxx`, folder + `file4.avi`])
        verifyEq(Uri[`file1.txt`, `file3.png`, `file5.xxx`, `file4.avi`], uris)
    }
}
