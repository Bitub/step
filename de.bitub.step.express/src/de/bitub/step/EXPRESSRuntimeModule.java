/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */

package de.bitub.step;

import org.eclipse.xtext.generator.IGenerator;

import de.bitub.step.generator.XcoreGenerator;

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
public class EXPRESSRuntimeModule extends de.bitub.step.AbstractEXPRESSRuntimeModule {

  @Override
  public Class<? extends IGenerator> bindIGenerator()
  {
    return XcoreGenerator.class;
  }
}
