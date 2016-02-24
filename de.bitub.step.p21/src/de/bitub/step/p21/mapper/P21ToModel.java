/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 14.07.2015.
 */
package de.bitub.step.p21.mapper;

import java.util.List;

import javax.management.InstanceNotFoundException;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

import de.bitub.step.p21.AllEntities;
import de.bitub.step.p21.AllParameters;
import de.bitub.step.p21.Registry;
import de.bitub.step.p21.StepParser.ParameterContext;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 14.07.2015
 */
public class P21ToModel implements AllEntities, AllParameters
{

  // holds all model informations and mappings
  //
  private Registry registry = Registry.INSTANCE();

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.AllParameters#allParametersBelongingTo(org.eclipse.emf.ecore.EObject)
   */
  @Override
  public List<EStructuralFeature> allParametersBelongingTo(EObject eObject)
  {
    return eObject.eClass().getEAllStructuralFeatures();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.AllParameters#withIndex()
   */
  @Override
  public ParameterContext withIndex()
  {
    throw new UnsupportedOperationException("Not implemented yet!");
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.AllEntities#withId(int)
   */
  @Override
  public EObject withId(int id)
  {
    throw new UnsupportedOperationException("Not implemented yet!");
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.AllEntities#add(org.eclipse.emf.ecore.EObject)
   */
  @Override
  public void add(EObject entity)
  {
    throw new UnsupportedOperationException("Not implemented yet!");
  }

  private EClassifier get(String keyword)
  {
    return registry.getNameMapping().get(keyword);
  }

  private EObject createEObjectBy(String name)
  {
    EClass eClass = (EClass) this.get(name);
    EObject eObject = EcoreUtil.create(eClass);
    return eObject;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @throws InstanceNotFoundException
   * @generated NOT
   * @see de.bitub.step.p21.AllEntities#addByName(java.lang.String)
   */
  @SuppressWarnings("unchecked")
  @Override
  public EObject addByName(String name) throws InstanceNotFoundException
  {
    name = name.toUpperCase();

    if (registry.getNameMapping().containsKey(name)) {

      EObject newObject = createEObjectBy(name);
      EList<EObject> curList = (EList<EObject>) registry.getLists().get(name); // TODO: Does this work?
      curList.add(newObject);
      return newObject;
    }

    throw new InstanceNotFoundException(name);
  }

  public void update(EObject object, EStructuralFeature feature, Object newValue)
  {
    try {
      object.eSet(feature, newValue);
    }
    catch (ClassCastException e) {
      e.printStackTrace();
    }
  }

  public EObject getContainer()
  {
    return registry.getContainer();
  }
}
