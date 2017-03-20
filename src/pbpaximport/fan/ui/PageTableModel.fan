/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class PageTableModel : TableModel
{
    private static const Str[] cols := ["Name", "Ord", "PxFile", "Pts", "Lints"]

    private static const Color RED := Color.red.lighter(0.9f)

    [Page:pbpaximport::Point[]] pageIndex { private set }
    Page[] rows { private set }
    [Page:LintError[]]? lintErrorIndex { private set }

    private [Int:Str] templates
    Str defaultTemplate

    new make([Page:pbpaximport::Point[]] pageIndex, Str defaultTemplate, [Page:LintError[]]? lintErrorIndex := null)
    {
        this.pageIndex = pageIndex
        this.lintErrorIndex = lintErrorIndex
        this.rows = pageIndex.keys

        this.templates = Int:Str[:]
        this.defaultTemplate = defaultTemplate
    }

    override Int numCols()
    {
        return cols.size
    }

    override Int numRows()
    {
        return rows.size
    }

    override Int? prefWidth(Int col)
    {
        switch (col)
        {
            case 0:
                return 110
            case 1:
                return 110
            case 2:
                return 470
            case 3:
                return 50
            case 4:
                return 55
        }

        return null
    }

    override Str text(Int col, Int row)
    {
        switch (col)
        {
            case 0:
                return rows[row].name
            case 1:
                return createFromTemplate(row)
            case 2:
                return rows[row].pxFile
            case 3:
                return pageIndex[rows[row]].size.toStr
            case 4:
                errors := lintErrorIndex?.get(rows[row])
                return (errors == null || errors.isEmpty ? "" : errors.size.toStr)
        }

        return ""
    }

    override Color? bg(Int col, Int row)
    {
        errors := lintErrorIndex?.get(rows[row])
        return (errors != null && !errors.isEmpty ? RED : null)
    }

    override Str header(Int col)
    {
        return cols[col]
    }

    private Str createFromTemplate(Int row)
    {
        template := templates[row] ?: defaultTemplate
        page := rows[row]

        template = applyResTemplate(template, page.res)

        return template.replace("%title%", page.title ?: "no title")
    }

    private static Str applyResTemplate(Str template, Uri res)
    {
        regex := Regex<|%res\[(-?\d+)\]%|>

        map := [Str:Str][:]
        regexMatcher := regex.matcher(template);
	    while (regexMatcher.find())
        {
            searchStr := regexMatcher.group(0)
	        position := regexMatcher.group(1).toInt

            if (!map.containsKey(searchStr))
            {
                try
                {
                    map[searchStr] = res[position..position].toStr.replace("/", "")
                }
                catch (IndexErr e)
                {
                    map[searchStr] = "N/A"
                }
            }
	    }

        map.each |part, searchStr|
        {
            template = template.replace(searchStr, part)
        }

        return template
    }

    Void setTemplateToRows(Int[] rows, Str template)
    {
        rows.each |row|
        {
            templates[row] = template
        }
    }

    Void clearTemplates(Int[] rows)
    {
        rows.each |row|
        {
            templates.remove(row)
        }
    }
}
