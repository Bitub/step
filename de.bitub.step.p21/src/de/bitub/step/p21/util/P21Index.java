package de.bitub.step.p21.util;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.bitub.step.p21.util.P21IndexImpl.IdStructuralFeaturePair;
import de.bitub.step.p21.util.P21IndexImpl.ListTriple;

public interface P21Index
{
  P21Index eINSTANCE = P21IndexImpl.init();

  EObject retrieve(String id);

  Map<String, Collection<IdStructuralFeaturePair>> retrieveUnresolved();

  List<ListTriple> retrieveUnresolvedLists();

  EObject store(String id, EObject object);

  void store(String ref, String id, EStructuralFeature feature);

  void store(String ref, int listIndex, EObject listWrapper);

  void store(List<String> references, EObject listWrapper, EStructuralFeature feature);

  List<EObject> retrieveAll(List<String> references);
}
