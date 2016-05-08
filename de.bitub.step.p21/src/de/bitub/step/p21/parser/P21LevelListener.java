package de.bitub.step.p21.parser;

import org.antlr.v4.runtime.ParserRuleContext;

import de.bitub.step.p21.IndexUtil;
import de.bitub.step.p21.StepParser;
import de.bitub.step.p21.StepParser.ListContext;
import de.bitub.step.p21.StepParser.ParameterContext;
import de.bitub.step.p21.StepParser.ParameterListContext;
import de.bitub.step.p21.StepParserBaseListener;
import de.bitub.step.p21.StepParserListener;

public abstract class P21LevelListener extends StepParserBaseListener implements StepParserListener
{
  IndexUtil index;

  public P21LevelListener(IndexUtil index)
  {
    this.index = index;
  }

  @Override
  public void enterList(ListContext ctx)
  {
    index.levelDown();
  }

  @Override
  public void exitList(ListContext ctx)
  {
    index.levelUp();
  }

  @Override
  public void enterParameterList(ParameterListContext ctx)
  {
    index.levelDown();
  }

  public void exitParameter(ParameterContext ctx)
  {
    ParserRuleContext parentCtx = ctx.getParent();

    if (parentCtx instanceof StepParser.ParameterListContext || parentCtx instanceof StepParser.ListContext) {
      index.up();
    }
  }
}
