package de.bitub.step.p21;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.bitub.step.p21.AllP21EntitiesImpl.IdStructuralFeaturePair;
import de.bitub.step.p21.AllP21EntitiesImpl.ListTriple;

public interface AllP21Entities
{
  AllP21Entities eINSTANCE = AllP21EntitiesImpl.init();

  EObject retrieve(String id);

  Map<String, Collection<IdStructuralFeaturePair>> retrieveUnresolved();

  Collection<ListTriple> retrieveUnresolvedLists();

  EObject store(String id, EObject object);

  void store(String ref, String id, EStructuralFeature feature);

  void store(List<String> references, EObject listWrapper, EStructuralFeature feature);

  List<EObject> retrieveAll(List<String> references);
}
