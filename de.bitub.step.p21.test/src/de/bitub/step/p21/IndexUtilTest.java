package de.bitub.step.p21;

import static org.hamcrest.core.Is.is;
import static org.junit.Assert.assertThat;

import org.junit.Before;
import org.junit.Test;

import de.bitub.step.p21.parser.util.IndexUtil;
import de.bitub.step.p21.parser.util.IndexUtilImpl;

public class IndexUtilTest
{

  IndexUtil index = null;

  @Before
  public void before()
  {
    index = new IndexUtilImpl();
  }

  @Test
  public void upShouldResultInIndexOfOne()
  {
    index.up();
    assertThat(index.current(), is(0));
    assertThat(index.upper(), is(-1));
    assertThat(index.level(), is(0));
  }

  @Test
  public void usingUpTwiceShouldResultInCurrentIndexOf1()
  {
    index.up();
    index.up();
    assertThat(index.current(), is(1));
    assertThat(index.upper(), is(-1));
    assertThat(index.level(), is(0));
  }

  @Test
  public void onLevelDownShouldSavePreviousLevelIndex()
  {
    index.up();
    index.up();
    index.levelDown();
    assertThat(index.current(), is(0));
    assertThat(index.upper(), is(1));
    assertThat(index.level(), is(1));
  }

  @Test
  public void twoLevelDownShouldSavePreviousLevelIndex()
  {
    index.up();
    index.up();
    index.levelDown();
    index.up();
    index.up();
    index.up();
    index.up();
    index.levelDown();
    index.up();

    assertThat(index.current(), is(1));
    assertThat(index.upper(), is(4));
    assertThat(index.level(), is(2));
  }

  @Test
  public void twoLevelDownShouldHaveFirstLevelIndexOf2()
  {
    index.up();
    index.up();
    index.levelDown();
    index.up();
    index.up();
    index.up();
    index.up();
    index.levelDown();
    index.up();

    assertThat(index.entityLevelIndex(), is(1));
  }
}
