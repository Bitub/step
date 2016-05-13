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
package de.bitub.step.p21.persistence;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

import org.eclipse.emf.ecore.resource.Resource;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 16.04.2015
 */
public interface P21Resource extends Resource
{
  String OPTION_PACKAGE_NS_URI = "nsURI";

  String OPTION_E_PACKAGE = "ePackage";

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see org.eclipse.emf.ecore.resource.Resource#load(java.io.InputStream,
   *      java.util.Map)
   */
  @Override
  public void load(InputStream inputStream, Map<?, ?> options) throws IOException;
}
