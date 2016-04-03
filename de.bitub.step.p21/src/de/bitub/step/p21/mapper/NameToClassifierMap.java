package de.bitub.step.p21.mapper;

import org.eclipse.emf.ecore.EClassifier;

public interface NameToClassifierMap
{
  EClassifier getEClassifier(String name);
}
