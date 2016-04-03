package de.bitub.step.p21.util;

import java.util.List;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.Tree;
import org.antlr.v4.runtime.tree.Trees;

import de.bitub.step.p21.StepParser.ListContext;
import de.bitub.step.p21.StepParser.RealContext;

public class Antlr4Util
{
  public static boolean partOfList(ParserRuleContext ctx)
  {
    return Antlr4Util.isContextAncestorOf(ctx, ListContext.class);
  }

  public static boolean isAncestorOf(Tree t, Tree u)
  {
    if (t == null || u == null || t.getParent() == null)
      return false;
    Tree p = u.getParent();
    while (p != null) {
      if (t == p)
        return true;
      p = p.getParent();
    }
    return false;
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
  public static boolean isParentOf(ParserRuleContext ctx, Class<? extends ParserRuleContext> clazz)
  {
    return ctx.getParent().getClass().equals(clazz);
  }

  public static boolean partOfList(RealContext ctx, boolean multilist)
  {
    if (!multilist) {
      return partOfList(ctx);
    }
    long numOfListAncestors =
        Trees.getAncestors(ctx).stream().filter((tree) -> tree.getClass().equals(ListContext.class)).count();

    return numOfListAncestors > 1;
  }
}
