package de.bitub.step.p21.di;

import org.eclipse.emf.ecore.EPackage;

import de.bitub.step.p21.parser.P21EntityListener;

public interface P21ParserFactory
{
  P21EntityListener createWith(EPackage ePackage);
}
