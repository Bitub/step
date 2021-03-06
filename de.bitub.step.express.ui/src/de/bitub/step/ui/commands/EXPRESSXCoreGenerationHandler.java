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

package de.bitub.step.ui.commands;

import java.util.Map;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IHandler;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.xtext.util.StringInputStream;

import de.bitub.step.xcore.XcoreGenerator;

/**
 * <!-- begin-user-doc -->
 * Dedicated command handler to transform EXPRESS into OclInEcore files
 * manually.
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author bernold - 18.01.2015
 */
public class EXPRESSXCoreGenerationHandler extends AbstractHandler implements IHandler
{

  @Override
  public Object execute(ExecutionEvent event) throws ExecutionException
  {
    ISelection selection = HandlerUtil.getCurrentSelection(event);
    if (selection instanceof IStructuredSelection) {
      
      IStructuredSelection structuredSelection = (IStructuredSelection) selection;
      Object firstElement = structuredSelection.getFirstElement();
      
      if (firstElement instanceof IFile) {
        
        IFile file = (IFile) firstElement;
        
        URI uri = URI.createPlatformResourceURI(file.getFullPath().toString(), true);
        ResourceSet rs = new ResourceSetImpl();
        Resource xtextResource = rs.getResource(uri, true);
        
        XcoreGenerator xcoreGen = new XcoreGenerator();
        // TODO file.getProject().getFullPath().toString()
        
        for(Map.Entry<String, CharSequence> e : xcoreGen.compile(xtextResource).entrySet()) {
          
          IFile genFile = file.getParent().getFile(new Path(e.getKey()+".xcore")); //$NON-NLS-1$
          try {
            
            if(genFile.exists()) {
              genFile.delete(true, new NullProgressMonitor());
            }
            genFile.create(new StringInputStream(e.getValue().toString()), IResource.FORCE|IResource.REPLACE, new NullProgressMonitor());
          }
          catch (CoreException e1) {

            e1.printStackTrace();
          }        
        }
      }
    }
    return null;
  }

  @Override
  public boolean isEnabled()
  {
    return true;
  }

}
