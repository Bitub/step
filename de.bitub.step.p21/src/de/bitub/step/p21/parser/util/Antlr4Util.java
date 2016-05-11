package de.bitub.step.p21.parser.util;

import java.util.List;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.Tree;
import org.antlr.v4.runtime.tree.Trees;

import de.bitub.step.p21.StepParser.ListContext;

public class Antlr4Util
{
  public static boolean partOfList(ParserRuleContext ctx)
  {
    return Antlr4Util.isContextAncestorOf(ctx, ListContext.class);
  }

  /**
   * Check if there is an ancestor of a specific type.
   * 
   * @param ctx
   * @param clazz
   * @return
   */
  public static boolean isContextAncestorOf(ParserRuleContext ctx, Class<? extends ParserRuleContext> clazz)
  {
    List<? extends Tree> ancestors = Trees.getAncestors(ctx);
    for (int i = ancestors.size() - 1; i >= 0; i--) {
      if (ancestors.get(i).getClass().equals(clazz)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Check if parent is of specific type.
   * 
   * @param ctx
   * @param clazz
   * @return
   */
  public static boolean isDirectParentOf(ParserRuleContext ctx, Class<? extends ParserRuleContext> clazz)
  {
    return ctx.getParent().getClass().equals(clazz);
  }

}
