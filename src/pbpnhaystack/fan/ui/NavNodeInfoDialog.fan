/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
using [java] org.projecthaystack::HMarker

/**
 * @author 
 * @version $Revision:$
 */
class NavNodeInfoDialog : PbpWindow
{
    private NavNode navNode

    new make(Window parent, NavNode navNode) : super(parent)
    {
        this.mode = WindowMode.appModal
        this.size = Size(530, 600)

        this.navNode = navNode

        this.content = InsetPane()
        {
            it.content = EdgePane()
            {
                it.center = ScrollPane()
                {
                    it.content = GridPane()
                    {
                        it.numCols = 3
                    }.addAll(createRows())
                }
                it.bottom = EdgePane()
                {
                    it.center = Label()
                    it.right = Button() { it.text = "Close"; it.onAction.add |Event e| { close() } }
                }
            }
        }
    }

    private Widget[] createRows()
    {
        rows := Widget[,]

        grid := navNode.row.grid

        cols := Str[,]
        for (i := 0; i < grid.numCols; i++)
        {
            cols.add(grid.col(i).name)
        }

        cols.each |col|
        {
            val := navNode.row.get(col, false)
            if (val != null)
            {
                rows.add(Label() { it.text = grid.col(col).dis })
                rows.add(Label() { it.text = val.typeof.name })
                rows.add(EdgePane()
                {
                    it.center = Text() { it.text = (val is HMarker ? "√" : val.toString); it.editable = false }
                })
            }
        }

        return rows
    }
}
