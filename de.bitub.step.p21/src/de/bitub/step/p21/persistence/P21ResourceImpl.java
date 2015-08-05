/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 14.04.2015.
 */
package de.bitub.step.p21.persistence;

import java.io.IOException;
import java.io.InputStream;
import java.util.Collections;
import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.impl.ResourceImpl;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 14.04.2015
 */
public class P21ResourceImpl extends ResourceImpl implements P21Resource
{

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public P21ResourceImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public P21ResourceImpl(URI uri)
  {
    super(uri);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see org.eclipse.emf.ecore.resource.impl.ResourceImpl#doLoad(java.io.InputStream,
   *      java.util.Map)
   */
  @Override
  protected void doLoad(InputStream inputStream, Map<?, ?> options) throws IOException
  {
    P21Load p21Load = createP21Load(options);

    if (options == null) {
      options = Collections.EMPTY_MAP;
    }

    p21Load.load(this, inputStream, options);
  }

  protected P21Load createP21Load()
  {
    return new P21LoadImpl(createP21Helper());
  }

  protected P21Load createP21Load(Map<?, ?> options)
  {
    return createP21Load();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @return
   */
  private P21Helper createP21Helper()
  {
    return new P21HelperImpl(this);
  }

}
