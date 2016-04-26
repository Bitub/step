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
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.BailErrorStrategy;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ConsoleErrorListener;
import org.antlr.v4.runtime.DefaultErrorStrategy;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.atn.PredictionMode;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.util.EcoreUtil;

import com.google.inject.Guice;
import com.google.inject.Injector;

import de.bitub.step.p21.P21EntityListener;
import de.bitub.step.p21.P21ParserListener;
import de.bitub.step.p21.StepLexer;
import de.bitub.step.p21.StepParser;
import de.bitub.step.p21.concurrrent.P21DataLineRunnable;
import de.bitub.step.p21.di.P21Module;
import de.bitub.step.p21.mapper.NameToClassifierMap;
import de.bitub.step.p21.mapper.NameToClassifierMapImpl;
import de.bitub.step.p21.mapper.NameToContainerListsMap;
import de.bitub.step.p21.mapper.NameToContainerListsMapImpl;
import de.bitub.step.p21.util.LoggerHelper;
import de.bitub.step.p21.util.P21Index;
import de.bitub.step.p21.util.P21IndexImpl.IdStructuralFeaturePair;

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

  protected P21Resource resource;
  protected InputStream inputStream;
  protected P21Helper helper;
  protected Map<?, ?> options;

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
    this.resource = resource;
    this.inputStream = inputStream;
    this.options = options;

    EPackage ePackage = (EPackage) options.get("ePackage");

//    StepToModel stepToModel = new StepToModelImpl(ePackage.getEFactoryInstance(), (EClass) ePackage.getEClassifiers().get(1));
//    de.bitub.step.p21.P21ParserListener listener = new de.bitub.step.p21.P21ParserListener(stepToModel);

    Injector injector = Guice.createInjector(new P21Module());

    ExecutorService executor = Executors.newFixedThreadPool(10);
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
    System.out.println((System.currentTimeMillis() - start) + " ms to read lines.");

    EClass ifc4 = (EClass) ePackage.getEClassifier("IFC4");
    NameToContainerListsMap container = new NameToContainerListsMapImpl(ePackage, EcoreUtil.create(ifc4));

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

    System.out.println((System.currentTimeMillis() - start) + " ms to collect entities.");
    start = System.currentTimeMillis();

    // fill resource
    //
    futures.stream().filter(Objects::nonNull).map((future) -> {
      try {
        EObject object = future.get();
        return object;
      }
      catch (Exception e) {
        LOGGER.severe(e.getStackTrace().toString());
        return null;
      }
    }).filter(Objects::nonNull).forEach((o) -> {
      container.addEObject(o.eClass().getName(), o);
    });

    System.out.println((System.currentTimeMillis() - start) + " ms to save into resource.");
    start = System.currentTimeMillis();

    P21Index entites = injector.getInstance(P21Index.class);
    Map<String, Collection<IdStructuralFeaturePair>> unresolvedPairs = entites.retrieveUnresolved();

    for (String key : unresolvedPairs.keySet()) {
      final EObject toStore = entites.retrieve(key);

      executor.execute(() -> {

        for (IdStructuralFeaturePair pair : unresolvedPairs.get(key)) {
          try {
            EObject needs = entites.retrieve(pair.id);
            needs.eSet(pair.feature, toStore);
          }
          catch (ClassCastException e) {
            LOGGER.severe(e.getStackTrace().toString());
          }
        }
      });

    }

    executor.shutdown();
    System.out.println((System.currentTimeMillis() - start) + " ms to resolve references.");

    resource.getContents().add(container.getEntity());
  }

  private void parse(String line, P21ParserListener listener)
  {
    CharStream input = new ANTLRInputStream(line);
    StepLexer lexer = new StepLexer(input);
    TokenStream tokens = new CommonTokenStream(lexer);
    StepParser parser = new StepParser(tokens);

    // try with simpler/faster SLL(*)
    //
    parser.getInterpreter().setPredictionMode(PredictionMode.SLL);

    // we don't want error messages or recovery during first try
    //
    parser.removeErrorListeners();
    parser.setErrorHandler(new BailErrorStrategy());

    ParseTree tree = null;

    try {
//      long start = System.currentTimeMillis();
      tree = parser.entityInstance();
//      System.out.println((System.currentTimeMillis() - start) + " ms to create parse tree");
    }
    catch (RuntimeException ex) {

      if (ex.getClass() == RuntimeException.class && ex.getCause() instanceof RecognitionException) {

        // The BailErrorStrategy wraps the RecognitionExceptions in
        // RuntimeExceptions so we have to make sure we're detecting
        // a true RecognitionException not some other kind

        // rewind input stream
        //
        lexer.reset();

        // back to standard listeners/handlers
        //
        parser.addErrorListener(ConsoleErrorListener.INSTANCE);
        parser.setErrorHandler(new DefaultErrorStrategy());

        // try full LL(*)
        //
        parser.getInterpreter().setPredictionMode(PredictionMode.LL);

        tree = parser.exchangeFile();
      }
    }

    ParseTreeWalker walker = new ParseTreeWalker();
    walker.walk(listener, tree);
  }
}
