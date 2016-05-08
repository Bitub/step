package de.bitub.step.p21.mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;

public class NameToContainerListsMapImpl implements NameToContainerListsMap
{
  private Map<String, EList<EObject>> eNameToContainmentListMap = null;

  private EObject entitiesRootContainer = null;

  public NameToContainerListsMapImpl(EObject entitiesRootContainer)
  {
    this.entitiesRootContainer = entitiesRootContainer;
  }

  @Override
  public void addEntity(String entityName, EObject entity)
  {
    getContainmentList(entityName).add(entity);
  }

  @Override
  public void addEntities(List<EObject> entities)
  {
    for (EObject entity : entities) {

      if (Objects.nonNull(entity)) {
        addEntity(entity);
      }
    }
  }

  @Override
  public void addEntity(EObject entity)
  {
    String entityName = entity.eClass().getName();
    addEntity(entityName, entity);
  }

  @Override
  public EList<EObject> getContainmentList(String name)
  {
    if (null == eNameToContainmentListMap) {

      EList<EReference> containments = entitiesRootContainer.eClass().getEAllContainments();
      Map<String, EList<EObject>> result = new HashMap<>(containments.size());

      for (EReference eReference : containments) {

        String key = eReference.getName().toUpperCase(); // store all upper-case name
        Object containmentList = entitiesRootContainer.eGet(eReference);

        if (containmentList instanceof EList) {
          result.put(key, (EList<EObject>) containmentList);
        }
      }
      eNameToContainmentListMap = result;
    }
    return eNameToContainmentListMap.get(name.toUpperCase());
  }

  @Override
  public EObject getRootEntity()
  {
    return entitiesRootContainer;
  }
}
