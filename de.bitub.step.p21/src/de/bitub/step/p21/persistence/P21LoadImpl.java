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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

import org.eclipse.emf.common.util.ECollections;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

import com.google.inject.Guice;
import com.google.inject.Injector;

import de.bitub.step.p21.P21EntityListener;
import de.bitub.step.p21.concurrrent.P21DataLineRunnable;
import de.bitub.step.p21.di.P21Module;
import de.bitub.step.p21.mapper.NameToClassifierMap;
import de.bitub.step.p21.mapper.NameToClassifierMapImpl;
import de.bitub.step.p21.mapper.NameToContainerListsMap;
import de.bitub.step.p21.mapper.NameToContainerListsMapImpl;
import de.bitub.step.p21.util.LoggerHelper;
import de.bitub.step.p21.util.P21Index;
import de.bitub.step.p21.util.P21IndexImpl.IdStructuralFeaturePair;
import de.bitub.step.p21.util.P21IndexImpl.ListTriple;
import de.bitub.step.p21.util.XPressModel;

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

  private NameToContainerListsMap container;

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

    initResource(resource, inputStream);

  }

  private void initResource(P21Resource resource, InputStream inputStream) throws IOException
  {
    // extract entities from DATA section
    //
    List<Future<EObject>> futures = readEntityInstanceListFromDATA(inputStream);

    // put all entities under shared schema container
    //
    long start = System.currentTimeMillis();
    EObject schemaContainer = saveLooseEntitiesintoSchemaContainer(toList(futures));
    System.out.println((System.currentTimeMillis() - start) + " ms to collect entities in root container.");

    // link unresolved and already created entities
    //
    start = System.currentTimeMillis();
    linkUnresolvedReferences();
    System.out.println((System.currentTimeMillis() - start) + " ms to resolve references.");

    executor.shutdown();
    resource.getContents().add(schemaContainer);
  }

  private List<EObject> toList(List<Future<EObject>> futures)
  {
    List<EObject> entities = new ArrayList<>();

    for (Future<EObject> future : futures) {

      try {
        entities.add(future.get());
      }
      catch (InterruptedException | ExecutionException e) {
        LOGGER.severe(e.getStackTrace().toString());
      }
    }

    return entities;
  }

  private EObject saveLooseEntitiesintoSchemaContainer(List<EObject> entities)
  {
    // TODO derive container name from model
    container = new NameToContainerListsMapImpl(ePackage, "IFC4");
    for (EObject entity : entities) {
      if (!Objects.isNull(entity)) {
        addEntityTo(entity, container);
      }
    }
    return container.getRootEntity();
  }

  private void addEntityTo(EObject entity, NameToContainerListsMap container)
  {
    if (Objects.nonNull(entity)) {
      String entityName = entity.eClass().getName();
      container.addEObject(entityName, entity);
    }
  }

  private List<Future<EObject>> readEntityInstanceListFromDATA(InputStream inputStream) throws IOException
  {
    List<P21DataLineRunnable> tasks = new ArrayList<>();
    NameToClassifierMap nameToClassifierMap = new NameToClassifierMapImpl(ePackage);

    long start = System.currentTimeMillis();
    try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream))) {

      String line = "";
      boolean isDataSection = false;

      while ((line = br.readLine()) != null) {

        if (line.equalsIgnoreCase("ENDSEC;")) {
          isDataSection = false;
        }

        if (isDataSection) {
          P21EntityListener listener = injector.getInstance(P21EntityListener.class);
          listener.setPackage(ePackage);
          listener.setNameToClassifierMap(nameToClassifierMap);

          tasks.add(new P21DataLineRunnable(listener, line));
        }

        if (line.equalsIgnoreCase("DATA;")) {
          isDataSection = true;
        }
      }
    }
    System.out.println((System.currentTimeMillis() - start) + " ms to read lines of DATA section.");

    start = System.currentTimeMillis();

    // collect results
    //
    List<Future<EObject>> futures = null;
    try {
      futures = executor.invokeAll(tasks);
    }
    catch (InterruptedException e) {
      LOGGER.severe(e.getStackTrace().toString());
    }

    System.out.println((System.currentTimeMillis() - start) + " ms to parse entities.");

    return futures;
  }

  private void linkUnresolvedReferences()
  {
    P21Index index = injector.getInstance(P21Index.class);

    linkReferenceContainingEntities(index);
    linkReferencesContainingLists(index);
  }

  private void connectEntityWithUnresolvedReference(IdStructuralFeaturePair pair, P21Index index, EObject resolvedEntity)
  {
    try {
      EObject entity = index.retrieve(pair.id);

      if (XPressModel.isSelect(pair.feature) && !XPressModel.isDelegate(pair.feature)) {

        entity.eSet(pair.feature, prepareSelect(pair.feature, resolvedEntity));
      } else {

        if (XPressModel.isDelegate(pair.feature)) {

          entity.eSet(pair.feature, prepareDelegate(pair.feature, resolvedEntity));

        } else {
          entity.eSet(pair.feature, resolvedEntity);
        }
      }
    }
    catch (ClassCastException e) {
      e.printStackTrace();
      LOGGER.severe(e.getStackTrace().toString());

    }
  }

  private EObject prepareDelegate(EStructuralFeature feature, EObject resolvedEntity)
  {
//    System.out.println("Prepare Delegate: " + resolvedEntity.eClass().getName() + " into " + feature.getEType().getName() + "@"
//        + feature.getName());
    EObject delegate = null;
    EClass featureType = ((EClass) feature.getEType());

    if (featureType.isInterface()) {
      EClass interfaceType = featureType;

      // search for subtype of interface delegate
      //
      for (EStructuralFeature resFeature : resolvedEntity.eClass().getEAllStructuralFeatures()) {

        if (resFeature.getEType() instanceof EClass) {
          EClass featureClass = (EClass) resFeature.getEType();

          if (interfaceType.isSuperTypeOf(featureClass)) {
//            System.out.println(interfaceType.getName() + " > " + featureClass.getName());

            delegate = EcoreUtil.create(featureClass);
            delegate.eSet(((EReference) resFeature).getEOpposite(), resolvedEntity);
          } else {
//            System.out.println(interfaceType.getName() + " != " + featureClass.getName());
          }
        }
      }
    }

    return delegate;
  }

  private EObject prepareSelect(EStructuralFeature feature, EObject resolvedEntity)
  {
    // create select class
    //
    EObject select = EcoreUtil.create((EClass) feature.getEType());

    // set entity to correct select field
    //
    for (EStructuralFeature selectFeature : select.eClass().getEAllStructuralFeatures()) {
      if (selectFeature.getEType().isInstance(resolvedEntity)) {
        select.eSet(selectFeature, resolvedEntity);
      }
    }

    return select;
  }

  private void connectListWrapperWithUnresolvedReferences(ListTriple triple, P21Index index)
  {
    try {
      // resolve all references
      //
      List<EObject> entities = index.retrieveAll(triple.references); // IfcCartesianPoint

      // set entity list into correct list wrapper
      EObject listWrapper = triple.wrapper;
      EStructuralFeature innerListFeat = triple.feature;

      // get list          
      @SuppressWarnings("unchecked")
      final EList<EObject> list = (EList<EObject>) listWrapper.eGet(innerListFeat);

      boolean isSelectContainingFeature = XPressModel.isSelect(innerListFeat);
      boolean isDelegateContainingFeature = XPressModel.isDelegate(innerListFeat);
      if (isSelectContainingFeature || isDelegateContainingFeature) {

        if (isDelegateContainingFeature) {

          // handle DELEGATES & SELECT DELGATES list
          //
          EList<? extends EObject> delegates = ECollections
              .asEList(entities.stream().map(entity -> prepareDelegate(innerListFeat, entity)).collect(Collectors.toList()));
          ECollections.setEList(list, delegates);
        } else {

          // handle SELECTs list
          //
          EList<? extends EObject> selects = ECollections
              .asEList(entities.stream().map(entity -> prepareSelect(innerListFeat, entity)).collect(Collectors.toList()));
          ECollections.setEList(list, selects);
        }

//        if (isSelectContainingFeature) {
//
//          boolean isSelectDelegateContainingFeature = XPressModel.isSelectProxy(innerListFeat);
//          if (isSelectDelegateContainingFeature) {
//
//            // handle SELECT DELGATES list
//            //          
//            EList<? extends EObject> selects = ECollections
//                .asEList(entities.stream().map(entity -> prepareDelegate(innerListFeat, entity)).collect(Collectors.toList()));
//            ECollections.setEList(list, selects);
//          } else {
//
//            // handle SELECTs list
//            //
//            EList<? extends EObject> selects = ECollections
//                .asEList(entities.stream().map(entity -> prepareSelect(innerListFeat, entity)).collect(Collectors.toList()));
//            ECollections.setEList(list, selects);
//          }
//        } else {
//
//          // handle DELEGATES list
//          //
//          EList<? extends EObject> delegates = ECollections
//              .asEList(entities.stream().map(entity -> prepareDelegate(innerListFeat, entity)).collect(Collectors.toList()));
//          ECollections.setEList(list, delegates);
//        }

      } else {

        // handle ENTITY list
        //
        ECollections.setEList(list, ECollections.asEList(entities));
      }
    }
    catch (ClassCastException | ArrayStoreException | IllegalArgumentException | NullPointerException e) {
      e.printStackTrace();
      LOGGER.severe(e.getStackTrace().toString());
    }
  }

  private void linkReferenceContainingEntities(P21Index index)
  {
    index.retrieveUnresolved().forEach((reference, pairs) -> {
      EObject toBeSet = index.retrieve(reference);
      pairs.forEach((pair) -> {
        executor.execute(() -> connectEntityWithUnresolvedReference(pair, index, toBeSet));
      });
    });
  }

  private void linkReferencesContainingLists(P21Index index)
  {
    index.retrieveUnresolvedLists().forEach((triple) -> {
      executor.execute(() -> connectListWrapperWithUnresolvedReferences(triple, index));
    });
  }
}
