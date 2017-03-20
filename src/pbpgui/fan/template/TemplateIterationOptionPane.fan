/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using gfx

class TemplateIterationOptionPane : EdgePane
{
  InsetPane mainPane

  new make(Str title, Str desc)
  {
    top=GridPane{GuiUtil.makeTitle(title),Label{text=desc},}
    mainPane = InsetPane{}
    center=mainPane
  }

}

