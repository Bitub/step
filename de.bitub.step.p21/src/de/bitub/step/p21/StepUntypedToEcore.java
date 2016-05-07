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

import java.util.logging.Level;
import java.util.logging.Logger;

import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EEnum;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

import de.bitub.step.p21.util.LoggerHelper;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 16.04.2015
 */
public class StepUntypedToEcore
{
  private static final Logger LOGGER = LoggerHelper.init(Level.WARNING, StepUntypedToEcore.class);

  public static void setEStructuralFeature(int parameterIndex, EObject eObject, Object value)
  {
    EStructuralFeature eStructuralFeature = XPressModel.p21FeatureBy(eObject, parameterIndex);

    // is it an attribute
    //
    if (eStructuralFeature instanceof EAttribute) {
      EAttribute eAttribute = (EAttribute) eStructuralFeature;

      StepUntypedToEcore.setEAttribute(eAttribute, eObject, value);
    }

    // is it an reference
    //
    if (eStructuralFeature instanceof EReference) {
      EReference eReference = (EReference) eStructuralFeature;

      if (value instanceof EObject) {
        EObject eValue = (EObject) value;

        boolean isNotMatched = !eValue.eClass().getName().equals(eReference.getEType().getName());
        if (isNotMatched) {

          EClass eSelectClass = (EClass) eReference.getEType();

          // only when not abstract
          //
          if (!eSelectClass.isAbstract()) {
            EObject eSelectInstance = EcoreUtil.create(eSelectClass); // BOOM

            EStructuralFeature refersToEntity = null;

            for (EStructuralFeature curEStructuralFeature : eSelectClass.getEStructuralFeatures()) {

              boolean isReferingTypeSameAsOriginalValue =
                  curEStructuralFeature.getEType().getName().equals(eValue.eClass().getName());
              if (isReferingTypeSameAsOriginalValue) {
                LOGGER.warning("FOUND ERef: " + curEStructuralFeature);
                refersToEntity = curEStructuralFeature;
              }
            }

            if (refersToEntity != null) {

              StepUntypedToEcore.setEReference((EReference) refersToEntity, eSelectInstance, value);
              StepUntypedToEcore.setEReference(eReference, eObject, eSelectInstance);
              return;
            }
          }
        }
      }

      // TODO check if needed
      if (!XPressModel.isSelect(eReference)) {
        System.out.printf("%s@%s > %s with %s\n", eObject.eClass().getName(), eReference.getName(),
            eReference.getEType().getName(), value);
        StepUntypedToEcore.setEReference(eReference, eObject, value);
      } else {

        System.out.printf("%s@%s > %s with %s\n", eObject.eClass().getName(), eReference.getName(),
            eReference.getEType().getName(), value);
      }
    }
  }

  private static void setEAttribute(EAttribute eAttribute, EObject eObject, Object value)
  {
    eObject.eSet(eAttribute, value);
  }

  private static void setEReference(EReference eReference, EObject eObject, Object value)
  {
    eObject.eSet(eReference, value);
  }

  public static void eString(int index, EObject eObject, String value)
  {
    StepUntypedToEcore.setEStructuralFeature(index, eObject, value);
  }

  public static void eInteger(int index, EObject eObject, String value)
  {
    try {
      int newValue = Integer.parseInt(value, 10);
      StepUntypedToEcore.setEStructuralFeature(index, eObject, newValue);
    }
    catch (NumberFormatException exception) {
      LOGGER.severe(exception.getMessage());
    }
  }

  public static void eReal(int index, EObject eObject, String value)
  {
    try {
      double newValue = Double.parseDouble(value);
      StepUntypedToEcore.setEStructuralFeature(index, eObject, newValue);
    }
    catch (NumberFormatException exception) {
      LOGGER.severe(exception.getMessage());
    }
  }

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
}
