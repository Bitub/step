package de.bitub.step.p21.di;

import com.google.inject.AbstractModule;

import de.bitub.step.p21.AllP21Entities;
import de.bitub.step.p21.AllP21EntitiesImpl;
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
    bind(AllP21Entities.class).toInstance(AllP21EntitiesImpl.eINSTANCE);

    bind(IndexUtil.class).to(IndexUtilImpl.class);

    bind(P21ParserFactory.class).to(P21ParserFactoryImpl.class);
  }
}
