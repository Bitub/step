/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 19.04.2015.
 */
package de.bitub.step.p21.persistence;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EPackage;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 19.04.2015
 */
public class P21HelperImpl implements P21Helper
{

  protected P21Resource resource;
  protected URI resourceURI;
  protected boolean deresolve;
  protected EPackage.Registry packageRegistry;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public P21HelperImpl()
  {
    // TODO Auto-generated constructor stub
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public P21HelperImpl(P21Resource resource)
  {
    this();
    setResource(resource);
  }

  public void setResource(P21Resource resource)
  {
    this.resource = resource;

    if (resource == null) {

      resourceURI = null;
      deresolve = false;
      packageRegistry = EPackage.Registry.INSTANCE;
    } else {

      resourceURI = resource.getURI();
      deresolve = resourceURI != null && !resourceURI.isRelative() && resourceURI.isHierarchical();
      packageRegistry =
          resource.getResourceSet() == null ? EPackage.Registry.INSTANCE : resource.getResourceSet().getPackageRegistry();
    }
  }
}
