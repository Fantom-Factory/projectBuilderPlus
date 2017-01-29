/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi

class PbpWindow : Window
{

  new make(Window? parentWindow) : super(parentWindow)
  {
    icon = PBPIcons.pbpIcon16
  }

}
