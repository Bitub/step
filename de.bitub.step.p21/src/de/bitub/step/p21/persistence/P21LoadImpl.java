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

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.buildingsmart.ifc4.Ifc4Package;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;

import com.google.inject.Guice;
import com.google.inject.Injector;

import de.bitub.step.p21.AllP21Entities;
import de.bitub.step.p21.XPressModel;
import de.bitub.step.p21.concurrrent.P21DataLineTask;
import de.bitub.step.p21.concurrrent.P21ResolveReferencesListTask;
import de.bitub.step.p21.concurrrent.P21ResolveReferencesTask;
import de.bitub.step.p21.di.P21Module;
import de.bitub.step.p21.mapper.NameToContainerListsMap;
import de.bitub.step.p21.mapper.NameToContainerListsMapImpl;
import de.bitub.step.p21.parser.P21DataLineTasksGenerator;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 19.04.2015
 */
public class P21LoadImpl implements P21Load
{
  protected P21Resource resource;
  protected InputStream is;
  protected P21Helper helper;
  protected Map<?, ?> options;

  protected EPackage ePackage;

  private Injector injector = Guice.createInjector(new P21Module());
  private ExecutorService executor = Executors.newFixedThreadPool(10);

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public P21LoadImpl(P21Helper helper)
  {
    this.helper = helper;
  }

  protected void handleErrors() throws IOException
  {
    if (!resource.getErrors().isEmpty()) {
      Resource.Diagnostic error = resource.getErrors().get(0);
      if (error instanceof Exception) {
        throw new Resource.IOWrappedException((Exception) error);
      } else {
        throw new IOException(error.getMessage());
      }
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @throws Exception
   * @generated NOT
   * @see de.bitub.step.p21.persistence.P21Load#load(de.bitub.step.p21.persistence.P21Resource,
   *      java.io.InputStream, java.util.Map)
   */
  @Override
  public void load(P21Resource resource, InputStream inputStream, Map<?, ?> options) throws IOException
  {
    this.resource = resource;
    this.is = inputStream;
    this.options = options;

    this.ePackage = helper.getEPackage((String) options.get(P21Resource.OPTION_PACKAGE_NS_URI));

    if (this.ePackage == null) {
      this.ePackage = Ifc4Package.eINSTANCE;
    }
    load(resource, inputStream);
  }

  private void load(P21Resource resource, InputStream inputStream) throws IOException
  {
    // extract entities from DATA section
    //
    P21DataLineTasksGenerator taskGenerator = injector.getInstance(P21DataLineTasksGenerator.class);
    taskGenerator.setEPackage(ePackage);

    List<P21DataLineTask> taskList = taskGenerator.generateWorkTasksFrom(inputStream);

    // collect results
    //
    List<Future<EObject>> futures = new ArrayList<>();
    for (P21DataLineTask task : taskList) {
      futures.add(executor.submit(task));
    }

    // put all entities under shared schema container
    //
    EObject schemaContainer = saveLooseEntitiesintoSchemaContainer(helper.futuresToEntities(futures));

    // link unresolved and already created entities
    //
    linkUnresolvedReferences();

    executor.shutdown();
    resource.getContents().add(schemaContainer);

    helper = null;
    handleErrors();
  }

  private EObject saveLooseEntitiesintoSchemaContainer(List<EObject> entities)
  {
    EObject rootContainer = XPressModel.getRootContainer(ePackage);
    NameToContainerListsMap containmentListMap = new NameToContainerListsMapImpl(rootContainer);
    containmentListMap.addEntities(entities);
    return rootContainer;
  }

  private void linkUnresolvedReferences()
  {
    AllP21Entities index = injector.getInstance(AllP21Entities.class);
    linkReferenceContainingEntities(index);
    linkReferencesContainingLists(index);
  }

  private void linkReferenceContainingEntities(AllP21Entities index)
  {
    index.retrieveUnresolved().forEach((reference, pairs) -> {
      EObject toBeSet = index.retrieve(reference);

      pairs.forEach((pair) -> {
        EObject entity = index.retrieve(pair.id);
        executor.execute(new P21ResolveReferencesTask(pair.feature, entity, toBeSet));
      });
    });
  }

  private void linkReferencesContainingLists(AllP21Entities index)
  {
    index.retrieveUnresolvedLists().forEach((triple) -> {
      if (!Objects.isNull(triple)) {
        List<EObject> entities = index.retrieveAll(triple.references);
        executor.execute(new P21ResolveReferencesListTask(triple.feature, triple.wrapper, entities));
      }
    });
  }
}
