package de.bitub.step.p21.mapper;

import java.util.List;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;

public interface NameToContainerListsMap
{

  EObject getRootEntity();

  EList<? extends EObject> getContainmentList(String name);

  void addEntity(String name, EObject o);

  void addEntity(EObject entity);

  void addEntities(List<EObject> entities);

}
