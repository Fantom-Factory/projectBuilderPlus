/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui

/**
 * @author 
 * @version $Revision:$
 */
class MappingProgressWindow : PbpWindow
{
    private ProgressBar progressBar
    private Label titleLabel
    private Bool canClose

    new make(Window parent, Int max) : super.make(parent)
    {
        this.mode = WindowMode.appModal
        this.size = Size(600, 120)
        this.alwaysOnTop = true

        this.titleLabel = Label() { it.text = "..." }
        this.progressBar = ProgressBar() { it.max = max }

        this.onClose.add |Event e| { if (!canClose) e.consume }

        this.content = InsetPane()
        {
            it.content = EdgePane()
            {
                it.center = titleLabel
                it.bottom = progressBar
            }
        }

        reset("")
    }

    Void doClose()
    {
        canClose = true
        close
    }

    Void reset(Str msg)
    {
        titleLabel.text = msg
        progressBar.val = 0
    }

    Void step(Str msg, Int i)
    {
        titleLabel.text = msg
        progressBar.val = i
    }
}
