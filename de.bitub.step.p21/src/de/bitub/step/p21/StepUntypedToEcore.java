/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 16.04.2015.
 */
package de.bitub.step.p21;

import java.util.List;

import org.eclipse.emf.common.util.ECollections;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EEnum;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 16.04.2015
 */
public class StepUntypedToEcore
{
  public static void eEnum(int index, EObject eObject, String literal)
  {
    EStructuralFeature eStructuralFeature = XPressModel.p21FeatureBy(eObject, index);

    if (eStructuralFeature instanceof EAttribute) {

      EDataType eDataType = ((EAttribute) eStructuralFeature).getEAttributeType();
      Object created = EcoreUtil.createFromString(eDataType, literal);

      if (created != null) {
        eObject.eSet(eStructuralFeature, created);
      }
    }
  }

  public static void eSelect(EStructuralFeature selectFeature, EObject eObject, String typedName, Object value)
  {
    EObject select = prepareSelect(selectFeature, value, typedName);
    eObject.eSet(selectFeature, select);
  }

  public static EObject prepareSelect(EStructuralFeature selectFeature, Object entity, String typeName)
  {
    // create select class
    //
    EObject select = setSelectValue(selectFeature, entity);

    // set enumeration to indicate which value was set
    //
    setSelectEnumValue(select, typeName);
    return select;
  }

  private static void setSelectEnumValue(EObject select, String typeName)
  {
    EStructuralFeature enumFeature = XPressModel.getSelectEnumeration(select);

    // set enumeration to indicate which value was set
    //
    if (enumFeature.getEType() instanceof EEnum) {
      EEnum selectEnum = (EEnum) enumFeature.getEType();

      // set correct enumeration literal to identify which SELECT value was set
      //
      Object enumeration = EcoreUtil.createFromString(selectEnum, typeName);
      select.eSet(enumFeature, enumeration);
    }
  }

  private static EObject setSelectValue(EStructuralFeature selectFeature, Object entity)
  {
    // create select class
    //
    EObject select = EcoreUtil.create((EClass) selectFeature.getEType());

    // set entity to correct select field
    //
    EStructuralFeature valueFeature = XPressModel.selectFeature(select, entity);

    // set correct value into select
    //
    select.eSet(valueFeature, entity);
    return select;
  }

  public static EObject prepareSelect(EStructuralFeature selectFeature, EObject entity)
  {
    // create select class
    //
    EObject select = EcoreUtil.create((EClass) selectFeature.getEType());

    // set entity to correct select field
    //
    EStructuralFeature valueFeature = XPressModel.selectFeature(select, entity);

    // set correct value into select
    //
    select.eSet(valueFeature, entity);

    // set enumeration to indicate which value was set
    //
    setSelectEnumValue(select, valueFeature.getEType().getName().toUpperCase());

    return select;
  }

  // TODO improve
  public static EObject prepareDelegate(EStructuralFeature delegateFeature, EObject targetEntity)
  {
    EObject delegate = null;
    EClass superDelegateType = ((EClass) delegateFeature.getEType());

    if (superDelegateType.isInterface()) {
      EClass interfaceType = superDelegateType;

      // TODO find correct feature / not first one
      // search for subtype of interface delegate
      //
      for (EStructuralFeature curFeature : targetEntity.eClass().getEAllStructuralFeatures()) {

        if (curFeature.getEType() instanceof EClass) {
          EClass curFeatureType = (EClass) curFeature.getEType();

          if (interfaceType.isSuperTypeOf(curFeatureType)) {// && curFeature.isMany()) {

            // create delegate object and set first site of bi-reference
            //
            delegate = EcoreUtil.create(curFeatureType);
            try {
              delegate.eSet(((EReference) curFeature).getEOpposite(), targetEntity);
            }
            catch (ArrayIndexOutOfBoundsException e) {
              System.out.println("DELEGATE: " + curFeature + "  " + ((EReference) curFeature).getEOpposite());
            }
          }
        }
      }
    }

    return delegate;
  }

  // TODO improve
  public static EList<EObject> mapToResultantEntities(EStructuralFeature listFeature, List<EObject> entities)
  {
    EList<EObject> result = ECollections.newBasicEListWithCapacity(entities.size());

    // DELEGATEs && DELEGATE-SELECTs
    //
    if (XPressModel.isDelegate(listFeature)) {

      for (EObject entity : entities) {
        EObject delegate = StepUntypedToEcore.prepareDelegate(listFeature, entity);
        result.add(delegate);
      }
      return result;
    }

    // SELECTs
    //
    if (XPressModel.isSelect(listFeature)) {

      for (EObject entity : entities) {
        EObject delegate = StepUntypedToEcore.prepareSelect(listFeature, entity);
        result.add(delegate);
      }
      return result;
    }

    // ENTITYs
    //
    return ECollections.asEList(entities);
  }

  // TODO improve
  public static void connectEntityWithResolvedReference(EStructuralFeature feature, EObject entity, EObject resolvedEntity)
  {
    // handle SELECTS
    //
    if (XPressModel.isSelect(feature) && !XPressModel.isDelegate(feature)) {

      entity.eSet(feature, StepUntypedToEcore.prepareSelect(feature, resolvedEntity));
    } else {

      if (XPressModel.isDelegate(feature)) {

        entity.eSet(feature, StepUntypedToEcore.prepareDelegate(feature, resolvedEntity));
      } else {

        try {
          entity.eSet(feature, resolvedEntity);
        }
        catch (ArrayIndexOutOfBoundsException e) {
          System.out.println("UNRESOLVED: " + resolvedEntity + "  " + feature);
        }
      }
    }
  }
}
