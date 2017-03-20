/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class TemplateRecordWidget : Canvas
{
  Record rec
  new make(Record rec)
  {
    this.rec = rec
  }

  override Void onPaint(Graphics g)
  {
    w := size.w
    h := size.h
    g.brush = Color.red
    g.fillRect(0, 0, w, h)
    g.brush = Color.blue
    g.drawRect(0, 0, w-1, h-1)
  }
}
