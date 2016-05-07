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

import de.bitub.step.p21.P21Index;
import de.bitub.step.p21.P21IndexImpl.IdStructuralFeaturePair;
import de.bitub.step.p21.P21IndexImpl.ListTriple;
import de.bitub.step.p21.StepUntypedToEcore;
import de.bitub.step.p21.XPressModel;
import de.bitub.step.p21.concurrrent.P21DataLineTask;
import de.bitub.step.p21.di.P21Module;
import de.bitub.step.p21.mapper.NameToClassifierMap;
import de.bitub.step.p21.mapper.NameToClassifierMapImpl;
import de.bitub.step.p21.mapper.NameToContainerListsMap;
import de.bitub.step.p21.mapper.NameToContainerListsMapImpl;
import de.bitub.step.p21.parser.P21EntityListener;
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
//    executor.shutdown();

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
        EObject entity = future.get();

        if (Objects.nonNull(entity)) {
          entities.add(entity);
        } else {
          // TODO Should not occur.
        }
      }
      catch (InterruptedException | ExecutionException e) {
        e.printStackTrace();
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
    List<P21DataLineTask> taskList = new ArrayList<>();
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

          taskList.add(new P21DataLineTask(listener, line));
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
    List<Future<EObject>> resultList = null;
    try {
      resultList = executor.invokeAll(taskList);
    }
    catch (InterruptedException e) {
      e.printStackTrace();
      LOGGER.severe(e.getStackTrace().toString());
    }

    System.out.println((System.currentTimeMillis() - start) + " ms to parse entities.");

    return resultList;
  }

  private void linkUnresolvedReferences()
  {
    P21Index index = injector.getInstance(P21Index.class);

    linkReferenceContainingEntities(index);
    linkReferencesContainingLists(index);
  }

  private void connectEntityWithUnresolvedReference(IdStructuralFeaturePair pair, P21Index index, EObject resolvedEntity)
  {
    EObject entity = null;
//    try {
    entity = index.retrieve(pair.id);

    // handle SELECTS
    //
    if (XPressModel.isSelect(pair.feature) && !XPressModel.isDelegate(pair.feature)) {

      entity.eSet(pair.feature, StepUntypedToEcore.prepareSelect(pair.feature, resolvedEntity));
    } else {

      if (XPressModel.isDelegate(pair.feature)) {

        entity.eSet(pair.feature, createDelegate(pair.feature, resolvedEntity));
      } else {

        try {
          entity.eSet(pair.feature, resolvedEntity);
        }
        catch (ArrayIndexOutOfBoundsException e) {
          System.out.println("UNRESOLVED: " + resolvedEntity + "  " + pair.feature);
        }
      }
    }
//    }
//    catch (ClassCastException | ArrayIndexOutOfBoundsException e) {
//      e.printStackTrace();
//      LOGGER.severe(entity + " -> " + resolvedEntity);
//    }
  }

  private EObject createDelegate(EStructuralFeature delegateFeature, EObject targetEntity)
  {
    EObject delegate = null;
    EClass superDelegateType = ((EClass) delegateFeature.getEType());

//    try {
    if (superDelegateType.isInterface()) {
      EClass interfaceType = superDelegateType;

      // TODO find correct feature / not first one
      // search for subtype of interface delegate
      //
      for (EStructuralFeature curFeature : targetEntity.eClass().getEAllStructuralFeatures()) {

        if (curFeature.getEType() instanceof EClass) {
          EClass curFeatureType = (EClass) curFeature.getEType();

          if (interfaceType.isSuperTypeOf(curFeatureType)) {// && curFeature.isMany()) {

            // create delegate object and set first site of bi-reference
            //
            delegate = EcoreUtil.create(curFeatureType);
            try {
              delegate.eSet(((EReference) curFeature).getEOpposite(), targetEntity);
            }
            catch (ArrayIndexOutOfBoundsException e) {
              System.out.println("DELEGATE: " + curFeature + "  " + ((EReference) curFeature).getEOpposite());
            }
          }
        }
      }
    }
//    }
//    catch (NullPointerException | ArrayIndexOutOfBoundsException e) {
//      System.out.println(delegateFeature);
//      System.out.println(targetEntity);
//    }

    return delegate;
  }

  private void connectListWrapperWithUnresolvedReferences(ListTriple triple, P21Index index)
  {
    // resolve all references
    //
    EList<EObject> entities = mapToResultantEntities(triple.feature, index.retrieveAll(triple.references));

    // get list          
    @SuppressWarnings("unchecked")
    final EList<EObject> list = (EList<EObject>) triple.wrapper.eGet(triple.feature);

    try {
      ECollections.setEList(list, entities);
    }
    catch (ArrayIndexOutOfBoundsException e) {
      System.out.println("LIST: " + triple + " " + entities);
      e.printStackTrace();
    }
  }

  private EList<EObject> mapToResultantEntities(EStructuralFeature listFeature, List<EObject> entities)
  {
    EList<EObject> result = ECollections.newBasicEListWithCapacity(entities.size());

    // DELEGATEs && DELEGATE-SELECTs
    //
    if (XPressModel.isDelegate(listFeature)) {

      for (EObject entity : entities) {
        EObject delegate = createDelegate(listFeature, entity);
        result.add(delegate);
      }
      return result;
    }

    // SELECTs
    //
    if (XPressModel.isSelect(listFeature)) {

      for (EObject entity : entities) {
        EObject delegate = StepUntypedToEcore.prepareSelect(listFeature, entity);
        result.add(delegate);
      }
      return result;
    }

    // ENTITYs
    //
    return ECollections.asEList(entities);
  }

  private void linkReferenceContainingEntities(P21Index index)
  {
    index.retrieveUnresolved().forEach((reference, pairs) -> {

      EObject toBeSet = index.retrieve(reference);

      if (Objects.nonNull(toBeSet)) {
        pairs.forEach((pair) -> {

          if (Objects.nonNull(pair)) {
            executor.execute(() -> connectEntityWithUnresolvedReference(pair, index, toBeSet));
          } else {
            LOGGER.severe(pair.toString());
          }
        });
      }
    });
  }

  private void linkReferencesContainingLists(P21Index index)
  {
    index.retrieveUnresolvedLists().forEach((triple) -> {
      if (!Objects.isNull(triple)) {
        executor.execute(() -> connectListWrapperWithUnresolvedReferences(triple, index));
      }
    });
  }
}
