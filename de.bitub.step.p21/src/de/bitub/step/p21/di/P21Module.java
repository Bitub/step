package de.bitub.step.p21.di;

import com.google.inject.AbstractModule;
import com.google.inject.Provides;

import de.bitub.step.p21.P21EntityListener;
import de.bitub.step.p21.util.IndexUtil;
import de.bitub.step.p21.util.IndexUtilImpl;
import de.bitub.step.p21.util.P21Index;
import de.bitub.step.p21.util.P21IndexImpl;

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