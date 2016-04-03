package de.bitub.step.p21.util;

import java.util.Collection;
import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.bitub.step.p21.util.P21IndexImpl.IdStructuralFeaturePair;

public interface P21Index
{
  P21Index eINSTANCE = P21IndexImpl.init();

  EObject retrieve(String id);

  EObject store(String id, EObject object);

  void store(String ref, String id, EStructuralFeature feature);

  Map<String, Collection<IdStructuralFeaturePair>> retrieveUnresolved();
}
