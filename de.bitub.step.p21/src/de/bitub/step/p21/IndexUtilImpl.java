package de.bitub.step.p21;

import java.util.ArrayDeque;
import java.util.Deque;

public class IndexUtilImpl implements IndexUtil
{
  Deque<Integer> indexStack = new ArrayDeque<Integer>();

  private int curIndex = -1;
  private int upperIndex = -1;

  public void levelUp()
  {
    // restore old index from parent parameter list
    //
    curIndex = indexStack.isEmpty() ? -1 : indexStack.pop();
  }

  public void up()
  {
    curIndex++;
  }

  private boolean isEntityLevel()
  {
    return curIndex == -1;
  }

  public void levelDown()
  {
    if (!isEntityLevel()) {
      rememberLevelIndex();
    }

    curIndex = 0;
  }

  public void rememberLevelIndex()
  {
    indexStack.push(curIndex);
    upperIndex = curIndex;
  }

  public int upper()
  {
    return upperIndex;
  }

  public int current()
  {
    return curIndex;
  }

  @Override
  public int entityLevelIndex()
  {
    return indexStack.getLast();
  }

  @Override
  public int level()
  {
    return indexStack.size();
  }

  @Override
  public String toString()
  {
    return "Level: " + level() + " Index: " + current();
  }

  @Override
  public boolean isListLevel()
  {
    return indexStack.size() == 1;
  }

  @Override
  public boolean isNestedListLevel()
  {
    return indexStack.size() > 1;
  }
}
