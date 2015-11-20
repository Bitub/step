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
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 27.08.2015
 */
public class ParameterIterator<E extends EStructuralFeature> implements Iterator<E>
{

  List<E> featuresList = null;
  int curIndex = -1;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public ParameterIterator(List<E> list)
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
    int nextIndex = nextIndex(curIndex + 1);

    if (-1 < nextIndex && nextIndex < this.featuresList.size()) {
      return true;
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
    curIndex = nextIndex(curIndex + 1);
    return this.featuresList.get(curIndex);
  }

  private int nextIndex(int index)
  {

    boolean isFound = false;

    while (!isFound) {

      if (index == this.featuresList.size()) {
        return -1;
      }

      EStructuralFeature eStructuralFeature = this.featuresList.get(index);

      if (eStructuralFeature instanceof EReference) {
        EReference ref = (EReference) eStructuralFeature;

        EAnnotation eAnnotation = eStructuralFeature.getEAnnotation("http://www.bitub.de/express/XpressModel");

        boolean hasOpposite = ref.getEOpposite() != null;
        if (hasOpposite) {
          EReference oppRef = ref.getEOpposite();

          if (ref.isOrdered()) {

            boolean isProxy = eAnnotation != null && eAnnotation.getDetails().get("kind").equals("proxy");
            if (isProxy) {
              System.out.println("PROXY at " + ref.getName() + " reference FOUND" + " with opposite "
                  + oppRef.getEReferenceType());

              isFound = true;
              if (oppRef.isContainer()) {
                System.out.print("Opposite of PROXY is container ");
              }

              if (!oppRef.isMany()) {
                System.out.println("and refers to one");
              } else {
                System.out.println("and refers to many");
              }

              break;
            }

            if (!oppRef.isOrdered()) {
              isFound = true;
            } else {
              index++;
            }

          } else {

            index++;
          }

        } else {

          // this is a normal reference
          //
          isFound = true;
        }
      }

      // or valid attribute
      //
      if (eStructuralFeature instanceof EAttribute) {
        EAttribute eAttribute = (EAttribute) eStructuralFeature;

        if (!eAttribute.isDerived()) {
          isFound = true;
        } else {
          index++;
        }
      }
    }

    return index;
  }

  public int index()
  {
    return curIndex;
  }
}
