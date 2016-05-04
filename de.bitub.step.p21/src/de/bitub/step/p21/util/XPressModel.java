/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 16.06.2015.
 */
package de.bitub.step.p21.util;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.eclipse.emf.ecore.EModelElement;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 16.06.2015
 */
public class XPressModel implements XPressModelConstants
{

  public static boolean isDelegate(EModelElement eModelElement)
  {
    String kind = getPatternOf(eModelElement);
    return null != kind && kind.equalsIgnoreCase(DELEGATE);
  }

  public static boolean isDelegate(EStructuralFeature eStructuralFeature)
  {
    String kind = getPatternOf(eStructuralFeature);
    return null != kind && kind.equalsIgnoreCase(DELEGATE);
  }

  public static boolean isSelectProxy(EStructuralFeature eStructuralFeature)
  {
    String select = getSelectOf(eStructuralFeature);
    return isDelegate(eStructuralFeature) && null != select;
  }

  public static boolean isSelect(EModelElement eModelElement)
  {
    return null != getSelectOf(eModelElement);
  }

  public static boolean isSelect(EStructuralFeature eStructuralFeature)
  {
    return null != getSelectOf(eStructuralFeature);
  }

  private static String getSelectOf(EModelElement eModelElement)
  {
    return EcoreUtil.getAnnotation(eModelElement, XPRESS_MODEL_ANNOTATION_SRC, SELECT);
  }

  private static String getPatternOf(EModelElement eModelElement)
  {
    return XPressModel.geKeyOf(eModelElement, PATTERN);
  }

  private static String geKeyOf(EModelElement eModelElement, String key)
  {
    if (null == eModelElement) {
      return null;
    }
    return EcoreUtil.getAnnotation(eModelElement, XPRESS_MODEL_ANNOTATION_SRC, key);
  }

  public static EStructuralFeature p21FeatureBy(EObject eObject, int p21Index)
  {
    // filter only @P21 annotated features
    //
    List<EStructuralFeature> annotatedFeatures = eObject.eClass().getEAllStructuralFeatures().parallelStream()
        .filter((feature) -> Objects.nonNull(feature.getEAnnotation(P21_MODEL_ANNOTATION_SRC))).collect(Collectors.toList());

    if (annotatedFeatures.isEmpty() || annotatedFeatures.size() <= p21Index) {
      return null;
    }
    return annotatedFeatures.get(p21Index);
  }
}
