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
package de.bitub.step.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.generator.IOutputConfigurationProvider;

import com.google.inject.Binder;

import de.bitub.step.xcore.XcoreOutputConfigurationProvider;

/**
 * Use this class to register components to be used within the IDE.
 */
public class EXPRESSUiModule extends de.bitub.step.ui.AbstractEXPRESSUiModule
{
  
  public EXPRESSUiModule(AbstractUIPlugin plugin)
  {
    super(plugin);
  }

  @Override
  public void configure(Binder binder)
  {
    super.configure(binder);

    binder.bind(IOutputConfigurationProvider.class).to(XcoreOutputConfigurationProvider.class);
  }
}
