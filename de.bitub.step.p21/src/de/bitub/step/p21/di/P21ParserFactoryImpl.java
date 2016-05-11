package de.bitub.step.p21.di;

import org.eclipse.emf.ecore.EPackage;

import com.google.inject.Inject;
import com.google.inject.Provider;

import de.bitub.step.p21.AllP21Entities;
import de.bitub.step.p21.mapper.NameToClassifierMapImpl;
import de.bitub.step.p21.parser.P21EntityListener;
import de.bitub.step.p21.parser.util.IndexUtil;

public class P21ParserFactoryImpl implements P21ParserFactory
{
  private final Provider<AllP21Entities> p21IndexProvider;
  private final Provider<IndexUtil> indexProvider;

  @Inject
  public P21ParserFactoryImpl(Provider<AllP21Entities> p21IndexProvider, Provider<IndexUtil> indexProvider)
  {
    this.p21IndexProvider = p21IndexProvider;
    this.indexProvider = indexProvider;
  }

  @Override
  public P21EntityListener createWith(EPackage ePackage)
  {
    return new P21EntityListener(p21IndexProvider.get(), indexProvider.get(), new NameToClassifierMapImpl(ePackage));
  }

}
