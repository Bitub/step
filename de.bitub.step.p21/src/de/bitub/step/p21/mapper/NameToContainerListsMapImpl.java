package de.bitub.step.p21.mapper;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.util.EcoreUtil;

public class NameToContainerListsMapImpl implements NameToContainerListsMap
{
  private Map<String, EList<EObject>> containerLists = null;

  public EObject entity = null;

  public NameToContainerListsMapImpl(EPackage ePackage, String classifierName)
  {
    this.entity = EcoreUtil.create((EClass) ePackage.getEClassifier(classifierName));
    init(ePackage);
  }

  private void init(EPackage ePackage)
  {
    containerLists = keywordToContainmentList(entity);
  }

  @SuppressWarnings("unchecked")
  private Map<String, EList<EObject>> keywordToContainmentList(EObject container)
  {
    EList<EReference> containments = container.eClass().getEAllContainments();
    Map<String, EList<EObject>> containerLists = new HashMap<>(containments.size());

    for (EReference eReference : containments) {
      Object containmentList = container.eGet(eReference);

      if (containmentList instanceof EList) {
        containerLists.put(eReference.getName().toUpperCase(), (EList<EObject>) containmentList);
      }
    }

    return containerLists;
  }

  @Override
  public void addEObject(String name, EObject eObject)
  {
    getEList(name).add(eObject);
  }

  @Override
  public EList<EObject> getEList(String name)
  {
    return containerLists.get(name.toUpperCase());
  }

  @Override
  public EObject getRootEntity()
  {
    return entity;
  }
}
