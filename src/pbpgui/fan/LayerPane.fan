/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class LayerPane : TabPane
{
  Widget? selectedLayer := null
  new make() : super()
  {
      //uniformRows = true
  }

  Void addLayer(Widget layer)
  {
    add(Tab{text=layer->layer->name; layer,}) // remove this method?
   // numCols = children.size
    relayout
  }

}
