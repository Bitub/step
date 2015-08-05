/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 30.06.2015.
 */
package de.bitub.step.p21;

import javax.management.InstanceNotFoundException;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 30.06.2015
 */
public interface AllEntities
{
  EObject withId(int id);

  EObject addByName(String name) throws InstanceNotFoundException;

  void add(EObject entity);

}
