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
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;

import com.google.inject.Guice;
import com.google.inject.Injector;

import de.bitub.step.p21.P21Index;
import de.bitub.step.p21.XPressModel;
import de.bitub.step.p21.concurrrent.P21DataLineTask;
import de.bitub.step.p21.concurrrent.P21ResolveReferencesListTask;
import de.bitub.step.p21.concurrrent.P21ResolveReferencesTask;
import de.bitub.step.p21.di.P21Module;
import de.bitub.step.p21.mapper.NameToContainerListsMap;
import de.bitub.step.p21.mapper.NameToContainerListsMapImpl;
import de.bitub.step.p21.parser.P21DataLineTasksGenerator;
import de.bitub.step.p21.util.LoggerHelper;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 19.04.2015
 */
public class P21LoadImpl implements P21Load
{
  private static final Logger LOGGER = LoggerHelper.init(Level.SEVERE, P21LoadImpl.class);

  protected P21Helper helper;
  protected EPackage ePackage;

  private Injector injector = Guice.createInjector(new P21Module());
  private ExecutorService executor = Executors.newFixedThreadPool(10);

  private NameToContainerListsMap containmentListMap;

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

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.persistence.P21Load#load(de.bitub.step.p21.persistence.P21Resource,
   *      java.io.InputStream, java.util.Map)
   */
  @Override
  public void load(P21Resource resource, InputStream inputStream, Map<?, ?> options) throws IOException
  {
    this.ePackage = (EPackage) options.get("ePackage");
    load(resource, inputStream, (EPackage) options.get("ePackage"));
  }

  private void load(P21Resource resource, InputStream inputStream, EPackage ePackage) throws IOException
  {
    // extract entities from DATA section
    //
    P21DataLineTasksGenerator taskGenerator = injector.getInstance(P21DataLineTasksGenerator.class);
    taskGenerator.setEPackage(ePackage);

    List<P21DataLineTask> taskList = taskGenerator.generateWorkTasksFrom(inputStream);

    long start = System.currentTimeMillis();

    // collect results
    //
    List<Future<EObject>> futures = null;
    try {
      futures = executor.invokeAll(taskList);
    }
    catch (InterruptedException e) {
      e.printStackTrace();
      LOGGER.severe(e.getStackTrace().toString());
    }

    System.out.println((System.currentTimeMillis() - start) + " ms to parse entities.");

    // put all entities under shared schema container
    //
    start = System.currentTimeMillis();
    EObject schemaContainer = saveLooseEntitiesintoSchemaContainer(helper.futuresToEntities(futures));
    System.out.println((System.currentTimeMillis() - start) + " ms to collect entities in root container.");

    // link unresolved and already created entities
    //
    start = System.currentTimeMillis();
    linkUnresolvedReferences();
    System.out.println((System.currentTimeMillis() - start) + " ms to resolve references.");

    executor.shutdown();
    resource.getContents().add(schemaContainer);
  }

  private EObject saveLooseEntitiesintoSchemaContainer(List<EObject> entities)
  {
    EObject rootContainer = XPressModel.getRootContainer(ePackage);
    containmentListMap = new NameToContainerListsMapImpl(rootContainer);
    containmentListMap.addEntities(entities);
    return rootContainer;
  }

  private void linkUnresolvedReferences()
  {
    P21Index index = injector.getInstance(P21Index.class);

    linkReferenceContainingEntities(index);
    linkReferencesContainingLists(index);
  }

  private void linkReferenceContainingEntities(P21Index index)
  {
    index.retrieveUnresolved().forEach((reference, pairs) -> {
      EObject toBeSet = index.retrieve(reference);

      pairs.forEach((pair) -> {
        EObject entity = index.retrieve(pair.id);
        executor.execute(new P21ResolveReferencesTask(pair.feature, entity, toBeSet));
      });
    });
  }

  private void linkReferencesContainingLists(P21Index index)
  {
    index.retrieveUnresolvedLists().forEach((triple) -> {
      if (!Objects.isNull(triple)) {
        List<EObject> entities = index.retrieveAll(triple.references);
        executor.execute(new P21ResolveReferencesListTask(triple.feature, triple.wrapper, entities));
      }
    });
  }
}
