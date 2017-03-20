/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class WizardStepsPane : ContentPane
{
    Int currentPage { private set }
    Int pagesCount { private set }

    private Button btnCancel
    private Button btnBack
    private Button btnForward
    private Button btnFinish

    private Label lblPosition
    private Label lblMessage

    private GridPane buttonsPane
    private EdgePane edgePane

    private |Int, Int -> Bool|? canGotoPageFunc
    private |Int, Int -> Void| onPageChangeFunc
    private |Int -> Void| onCancelFunc
    private |Int -> Void| onFinishFunc
    private |Int -> Str|? getMessageFunc

    new make(Int pagesCount, |Int, Int -> Void| onPageChangeFunc, |Int -> Void| onCancelFunc, |Int -> Void| onFinishFunc, |Int -> Str|? getMessageFunc := null, |Int, Int -> Bool|? canGotoPageFunc := null)
    {
        this.pagesCount = pagesCount
        this.canGotoPageFunc = canGotoPageFunc
        this.onCancelFunc = onCancelFunc
        this.onFinishFunc = onFinishFunc
        this.getMessageFunc = getMessageFunc
        this.onPageChangeFunc = onPageChangeFunc

        btnCancel = Button.makeCommand(Command("Cancel", null, |Event e| { onCancelFunc(currentPage) }))
        btnBack = Button.makeCommand(Command("< Back", null, |Event e| { previousPage }))
        btnForward = Button.makeCommand(Command("Forward >", null, |Event e| { nextPage }))
        btnFinish = Button.makeCommand(Command("Finish", null, |Event e| { onFinishFunc(currentPage) }))

        lblPosition = Label() { text = "0/0" }
        lblMessage = Label() { text = "" }

        buttonsPane = GridPane() { numCols = 4; btnCancel, btnBack, btnForward, btnFinish, }

        content = EdgePane() { it.top = InsetPane(0, 5, 5, 5) { it.content = edgePane = EdgePane()
        {
            it.left = ConstraintPane() { it.minw = 50; it.content = lblPosition }
            it.center = lblMessage
            it.right = buttonsPane
        } } }

        relayoutAfterUpdate
    }

    private Void relayoutAfterUpdate()
    {
        buttonsPane.relayout
        edgePane.relayout
    }

    Void previousPage()
    {
        gotoPage(currentPage - 1)
    }

    Void nextPage()
    {
        gotoPage(currentPage + 1)
    }

    Void gotoPage(Int page)
    {
        lastPage := currentPage

        page = (page <= 0 ? 1 : (page > pagesCount ? pagesCount : page ) )

        if ((currentPage != page && canGotoPage(lastPage, page)))
        {
            currentPage = page
            update()

            onPageChangeFunc(currentPage, lastPage)
        }
    }

    private Bool canGotoPage(Int currentPage, Int newPage)
    {
        return canGotoPageFunc != null ? canGotoPageFunc(currentPage, newPage) : true
    }

    private Void update()
    {
        if (currentPage <= 1)
        {
            btnCancel.visible = true
            btnBack.visible = false
            btnForward.visible = true
            btnFinish.visible = false
        }
        else if (currentPage >= pagesCount)
        {
            btnCancel.visible = false
            btnBack.visible = true
            btnForward.visible = false
            btnFinish.visible = true
        }
        else
        {
            btnCancel.visible = false
            btnBack.visible = true
            btnForward.visible = true
            btnFinish.visible = false
        }

        lblPosition.text = "${currentPage}/$pagesCount"

        lblMessage.text = getMessageFunc != null ? getMessageFunc(currentPage) : ""

        relayoutAfterUpdate
    }

}
