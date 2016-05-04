package de.bitub.step.p21.mapper;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;

public interface NameToContainerListsMap
{

  EObject getRootEntity();

  EList<? extends EObject> getEList(String name);

  void addEObject(String name, EObject o);

}
