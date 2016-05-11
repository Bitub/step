package de.bitub.step.p21.di;

import com.google.inject.AbstractModule;

import de.bitub.step.p21.P21Index;
import de.bitub.step.p21.P21IndexImpl;
import de.bitub.step.p21.parser.util.IndexUtil;
import de.bitub.step.p21.parser.util.IndexUtilImpl;

public class P21Module extends AbstractModule
{
//  private EPackage ePackage;
//
//  public P21Module()
//  {
//  }
//
//  public P21Module(EPackage ePackage)
//  {
//    this.ePackage = ePackage;
//  }

  @Override
  protected void configure()
  {
    bind(P21Index.class).toInstance(P21IndexImpl.eINSTANCE);

    bind(IndexUtil.class).to(IndexUtilImpl.class);

    bind(P21ParserFactory.class).to(P21ParserFactoryImpl.class);
  }
}
