package de.bitub.step.p21.di;

import com.google.inject.AbstractModule;
import com.google.inject.Provides;

import de.bitub.step.p21.IndexUtil;
import de.bitub.step.p21.IndexUtilImpl;
import de.bitub.step.p21.P21Index;
import de.bitub.step.p21.P21IndexImpl;
import de.bitub.step.p21.parser.P21EntityListener;

public class P21Module extends AbstractModule
{

  @Override
  protected void configure()
  {
    bind(P21Index.class).toInstance(P21IndexImpl.eINSTANCE);

    bind(IndexUtil.class).to(IndexUtilImpl.class);
  }

  @Provides
  P21EntityListener provideP21EntityListener(P21Index entities, IndexUtil index)
  {
    return new P21EntityListener(entities, index);
  }
}
