package de.bitub.step.p21.parser.util;

public interface IndexUtil
{
  void levelDown();

  void levelUp();

  void up();

  int current();

  int upper();

  int level();

  int entityLevelIndex();

  boolean isNestedListLevel();

  boolean isListLevel();
}
