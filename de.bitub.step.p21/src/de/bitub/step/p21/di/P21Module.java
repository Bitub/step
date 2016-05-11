package de.bitub.step.p21.di;

import com.google.inject.AbstractModule;

import de.bitub.step.p21.IndexUtil;
import de.bitub.step.p21.IndexUtilImpl;
import de.bitub.step.p21.P21Index;
import de.bitub.step.p21.P21IndexImpl;

public class P21Module extends AbstractModule
{

  @Override
  protected void configure()
  {
    bind(P21Index.class).toInstance(P21IndexImpl.eINSTANCE);

    bind(IndexUtil.class).to(IndexUtilImpl.class);

    bind(P21ParserFactory.class).to(P21ParserFactoryImpl.class);
  }
}
