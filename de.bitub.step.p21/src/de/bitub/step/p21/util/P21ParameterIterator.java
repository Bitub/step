/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 27.08.2015.
 */
package de.bitub.step.p21.util;

import java.util.Iterator;
import java.util.List;

import org.eclipse.emf.ecore.EAnnotation;
import org.eclipse.emf.ecore.EStructuralFeature;

/**
 * <!-- begin-user-doc -->
 * Stateful parameter iterator using @P21 model annotations.
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemschüssel - 07.12.15
 */
public class P21ParameterIterator<E extends EStructuralFeature> implements Iterator<E>
{
  private static final String SOURCE_URI = "http://www.bitub.de/express/P21";

  List<E> featuresList = null;
  int curIndex = -1;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public P21ParameterIterator(List<E> list)
  {
    this.featuresList = list;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see java.util.Iterator#hasNext()
   */
  @Override
  public boolean hasNext()
  {
    int pointer = curIndex + 1; // restore old index state

    // go forward until new annotation found, else no NEXT
    //
    while (pointer < this.featuresList.size()) {

      EStructuralFeature eStructuralFeature = this.featuresList.get(pointer);
      EAnnotation eAnnotation = eStructuralFeature.getEAnnotation(SOURCE_URI);

      if (eAnnotation != null) {
        return true;
      }
      pointer++;
    }

    return false;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see java.util.Iterator#next()
   */
  @Override
  public E next()
  {
    int pointer = curIndex + 1; // restore old index state

    // go forward until new annotation found, else no NEXT
    //
    while (pointer < this.featuresList.size()) {

      EStructuralFeature eStructuralFeature = this.featuresList.get(pointer);
      EAnnotation eAnnotation = eStructuralFeature.getEAnnotation(SOURCE_URI);

      if (eAnnotation != null) {

        curIndex = pointer;
        return featuresList.get(curIndex);
      }
      pointer++;
    }

    return null;
  }

  public int index()
  {
    return curIndex;
  }
}
