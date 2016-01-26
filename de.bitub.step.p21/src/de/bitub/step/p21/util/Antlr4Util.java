package de.bitub.step.p21.util;

import org.antlr.v4.runtime.ParserRuleContext;

import de.bitub.step.p21.StepParser;

public class Antlr4Util
{

  public static boolean isParentOfType(ParserRuleContext ctx, Class<? extends ParserRuleContext> class1)
  {
    // has a parent
    //
    if (ctx.getClass().equals(class1.getClass())) {
      return true;
    }

    // stop on root ctx
    //
    if (ctx instanceof StepParser.ExchangeFileContext) {
      return false;
    }
    return isParentOfType(ctx.getParent(), class1);
  }
}
