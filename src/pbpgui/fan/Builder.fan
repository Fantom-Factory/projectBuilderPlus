/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class Builder : PbpWindow
{
  SashPane? _mainWrapper
  SashPane? _centerWrapper
  SashPane? _leftWrapper
  SashPane? _rightWrapper

  TabPane _recordTabs := TabPane()
  TabPane _treeTabs := TabPane()
  TabPane _connTabs := TabPane()
  TabPane _tagTabs := TabPane()
  TabPane _templateTabs := TabPane()
  TabPane _auxTabs := TabPane()

  ProgressBar _pbar := ProgressBar()


   //test._treeTabs =

  //propSheet
  InsetPane _propSheetWrapper := InsetPane()

  Button? _rightButton
  Button? _leftButton

  new make(Window? parent := null):super(parent)
  {
    _leftWrapper = SashPane{
      weights = [645,258]
      orientation = Orientation.vertical
      _connTabs,
      _auxTabs
    }

    _centerWrapper = SashPane{
      orientation = Orientation.vertical
      _recordTabs,
      _treeTabs,
    }

    _rightWrapper = SashPane{
      weights = [449,451]
      orientation = Orientation.vertical
      _tagTabs,
      _templateTabs,
    }

    _mainWrapper = SashPane{
    weights = [258,765,445]
    _leftWrapper,
    _centerWrapper,
    _rightWrapper,
    }
  }

  override Obj? open()
  {
    size  = Size(1500,1000)
    content = EdgePane{
      center=_mainWrapper
      bottom=_pbar
      }
    return super.open()
  }


}


