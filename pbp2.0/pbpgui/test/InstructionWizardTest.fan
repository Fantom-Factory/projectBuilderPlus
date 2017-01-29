/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class InstructionWizardTest : Test
{
  Void testInstructionThing()
  {
    Instruction[] instructions1 := [Instruction("test1"), Instruction("test2"), Instruction("test3")]
    Instruction[] instructions2 := [Instruction("test1"), Instruction("test2"), Instruction("test3")]
    Instruction[] instructions3 := [Instruction("test1"), Instruction("test2"), Instruction("test3")]
    Window{
      content = GridPane{
        InstructionBox("test1", instructions1),
        InstructionBox("test2", instructions2),
        InstructionBox("test3", instructions3),
      }
    }.open
  }

  Void testWizard()
  {
    Instruction[] instructions1 := [
      Instruction("Must have these tags:").addField(InstructionSmartBox(StrTag{name="test";val="test"})),
      Instruction("Must have these tags with these values:"),
      Instruction("You can find the parent reference from this tag:"),
      Instruction("Please inheret these tags from the parent:"),
      Instruction("Must be this type of Record:").addField(Combo{items=["site","equip","point"]})
      ]
    Instruction[] instructions2 := [Instruction("test1"), Instruction("test2"), Instruction("test3")]
    Instruction[] instructions3 := [Instruction("test1"), Instruction("test2"), Instruction("test3")]
    Instruction[] instructions4 := [Instruction("test1"), Instruction("test2"), Instruction("test3")]
    Instruction[] instructions5 := [Instruction("test1"), Instruction("test2"), Instruction("test3")]
    Instruction[] instructions6 := [Instruction("test1"), Instruction("test2"), Instruction("test3")]

    InstructionBox test1 := InstructionBox("test1", instructions1)
    InstructionBox test2 := InstructionBox("test2", instructions2)
    InstructionBox test3 := InstructionBox("test3", instructions3)
    InstructionBox test4 := InstructionBox("test4", instructions4)
    InstructionBox test5 := InstructionBox("test5", instructions5)
    InstructionBox test6 := InstructionBox("test6", instructions6)
    InstructionBox[] boxes := [test1, test2, test3, test4, test5, test6]

    Wizard wiz := Wizard(null)
    {
      it.boxes = boxes
      it.tagExp = TagExplorer.makeWithCombo(FileUtil.getTagDir+`standard.taglib`, Command(), Combo(), true)
    }.open
  }
}
