/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

class WidgetUtils
{
    static Widget? findWidgetOfType(Widget[] widgets, Type[] types)
    {
        if (widgets.isEmpty)
        {
            return null // continue
        }
        else
        {
            return widgets.eachWhile |widget -> Obj?|
            {
                if (types.any |Type type -> Bool| { Type.of(widget).fits(type) })
                {
                    return widget
                }
                else
                {
                    return findWidgetOfType(widget.children, types)
                }
            }
        }
    }
}
