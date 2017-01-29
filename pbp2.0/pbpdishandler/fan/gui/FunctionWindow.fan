/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
using pbpcore

class FunctionWindow : PbpWindow
{
  private FunctionDesc fdesc
  private RuleDesc rdesc
  private ApplicationDesc adesc
  private RuleDescriptionTable rdesctable
  private ApplyDescriptionTable adesctable

  new make(Window? parent := null, DisFunc func := DisFunc{displayName="test";rules=[,]; applies=[,]}) : super(parent)
  {
    fdesc = FunctionDesc(func.displayName)
    rdesc = RuleDesc(func.getRules())
    adesc = ApplicationDesc(func.getUserValues(), func.getTagValues())
    rdesctable = RuleDescriptionTable(func)
    adesctable = ApplyDescriptionTable(func)
    title = "Function Handler"
    size = Size(823,636)
    content = EdgePane{
      center = TabPane{
        Tab
        {
        text="1. Build"
        SashPane{
        weights = [51,342,199]
        orientation = Orientation.vertical
        fdesc,
        rdesc,
        adesc,
        },
        },
        Tab
        {
        text="2. Rank"
        SashPane{
        orientation = Orientation.vertical
        rdesctable,
        adesctable,
        },
        },
      }
      bottom = EdgePane{
        right=GridPane{
          numCols=2;
          Button{text="Save"
          onAction.add|e|
          {
            onSaveClicked(e)
          }
          },
          Button{text="Close"
          onAction.add|e|{e.window.close}
          },
         }
      }
      }
  }

  private Void onSaveClicked(Event e)
  {
    DisFunc newDisFunc := save()
    EngineWindow ewindow := parent
    
    if(!(ewindow.currentFolder+(newDisFunc.displayName+".dfunc").toUri).exists)
    {
      ewindow.currentFolder.createFile(newDisFunc.displayName+".dfunc").writeObj(newDisFunc)
    }
    else
    {
      (ewindow.currentFolder+(newDisFunc.displayName+".dfunc").toUri).writeObj(newDisFunc)
    }
    
    rdesctable.update(newDisFunc)
    adesctable.update(newDisFunc)
   
    rdesctable.refreshTables
    adesctable.refreshTables
  }

  DisFunc save()
  {
    Str name := (fdesc as Compilable).compile()
    Tag[] ruletags := (rdesc as Compilable).compile()
    List apps := (adesc as Compilable).compile()
    Str[] appstrs := apps[0]
    Tag[] apptags := apps[1]
    DisRule[] rules := [,]
    DisApply[] applies := [,]
    ruletags.each |rule|
    {
      if(rule.val!=null && rule.val!=""){rules.push(DisRuleValue{tagToCompare=rule})}
      else{rules.push(DisRuleContains{tagToFind=rule})}
    }
    appstrs.each |strs|
    {
      if(strs!="")
      {
        applies.push(DisApplyUser{valueToApply=strs})
      }
    }
    apptags.each |tags|
    {
      applies.push(DisApplyTag{tagToFind=tags})
    }
    DisRule[] orderedrules := rdesctable.getDescriptions
    orderedrules.each |rule,index|
    {
      Int? ruletocompare := rules.findIndex|DisRule r->Bool| {return r.desc()==rule.desc()}
      if(ruletocompare!=null)
      {
        if(index!=rules.size-1)
        {
         rules.swap(index,ruletocompare)
        }
      }
    }
    DisApply[] orderedapplies := adesctable.getDescriptions
    orderedapplies.each |apply,index|
    {
      Int? applytocompare := applies.findIndex|DisApply a->Bool| {return a.desc==apply.desc()}
      if(applytocompare !=null)
      {
        if(index<applies.size-1)
        {
          applies.swap(index,applytocompare)
        }
      }
    }
    return DisFunc{
      displayName=name
      it.rules=rules
      it.applies=applies}
  }
}


class Main
{
  Void main()
  {
    FunctionWindow().open()
  }
}
