package de.bitub.step.p21.mapper;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EPackage;

public class NameToClassifierMapImpl implements NameToClassifierMap
{
  private Map<String, EClassifier> stepToEcoreNames = null;

  public NameToClassifierMapImpl(EPackage ePackage)
  {
    init(ePackage);
  }

  private void init(EPackage ePackage)
  {
    stepToEcoreNames = nameToClassifier(ePackage.getEClassifiers());
  }

  private Map<String, EClassifier> nameToClassifier(EList<EClassifier> eClassifiers)
  {
    Map<String, EClassifier> stepToEcoreNames = new HashMap<>(eClassifiers.size());

    for (EClassifier eClassifier : eClassifiers) {
      stepToEcoreNames.put(eClassifier.getName().toUpperCase(), eClassifier);
    }

    return stepToEcoreNames;
  }

  @Override
  public EClassifier getEClassifier(String name)
  {
    return stepToEcoreNames.get(name.toUpperCase());
  }
}
