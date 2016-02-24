package de.bitub.step.p21.util;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.Tree;
import org.antlr.v4.runtime.tree.Trees;

import de.bitub.step.p21.StepParser;

public class Antlr4Util {

	public static boolean isAncestorOf(Tree t, Tree u) {
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
	public static boolean isContextAncestorOf(ParserRuleContext ctx,
			Class<? extends ParserRuleContext> clazz) {
		Trees.getAncestors(ctx);

		// has a parent
		//
		if (ctx.getClass().equals(clazz)) {
			return true;
		}

		// stop on root context
		//
		if (ctx instanceof StepParser.ExchangeFileContext) {
			return false;
		}
		return isContextAncestorOf(ctx.getParent(), clazz);
	}

	/**
	 * Check if parent is of specific type.
	 * 
	 * @param ctx
	 * @param clazz
	 * @return
	 */
	public static boolean isParentOf(ParserRuleContext ctx,
			Class<? extends ParserRuleContext> clazz) {
		return ctx.getParent().getClass().equals(clazz);
	}
}
