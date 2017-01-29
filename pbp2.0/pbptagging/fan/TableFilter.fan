/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using [java] java.util.regex::Pattern as JPattern

class TableFilter
{
    private Table table
    private Text textCount
    private TaggingTableModel model

    private [Str:Regex] regexCache

    new make(Table table, Text textCount)
    {
        this.table = table
        this.textCount = textCount
        this.model = table.model as TaggingTableModel ?: throw Err("Invalid table.model $table.model")
        this.regexCache = [:]
    }

    Void refreshModel()
    {
        model = table.model as TaggingTableModel ?: throw Err("Invalid table.model $table.model")
    }

    Void filter(Bool suggestInFile, Str filter)
    {
        suggestFile := (suggestInFile && !table.selected.isEmpty ?
            model.getRow(table.selected.first).file :
            null)

        try
        {

            if (filter == "")
            {
                model.filter(suggestFile)
            }
            else
            {

                regex := regexCache[filter]

                if (regex == null)
                {
                    items := filter.split(' ').
                        findAll |Str item -> Bool| { !item.isEmpty && !item[0].isSpace }.
                        map |Str item ->Str| { JPattern.quote(item) }

                    regexStr := items.reduce("(?i)") |Str reduction, Str item -> Str| { "${reduction}(?=.*${item})" }

                    regex = Regex.fromStr("${regexStr}.+")
                    regexCache[filter] = regex
                }

                model.filter(suggestFile, regex)
            }
        }
        finally
        {
            textCount.text = (model.numRows > 0 ? "$model.numRows row(s)" : "empty") +
                (suggestFile != null ? ". In file ${suggestFile.name}" : "")
            table.refreshAll
            table.selected = (model.numRows > 0 ? [0] : [,])
        }
    }
}
