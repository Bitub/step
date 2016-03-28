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
import java.util.Map;
import java.util.Scanner;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

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
import org.eclipse.emf.ecore.EFactory;
import org.eclipse.emf.ecore.EPackage;

import de.bitub.step.p21.P21ParserListener;
import de.bitub.step.p21.StepLexer;
import de.bitub.step.p21.StepParser;
import de.bitub.step.p21.mapper.StepToModel;
import de.bitub.step.p21.mapper.StepToModelImpl;

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
  protected InputStream inputStream;
  protected P21Helper helper;
  protected Map<?, ?> options;

  private static final String ID_AT_START_REGEX = "^#\\d+";
  private static final Pattern ID_AT_START = Pattern.compile(ID_AT_START_REGEX);

  public static final String E_PACKAGE_OPTION = "ePackage";

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

  private static boolean startsWithEntityId(String text)
  {
    return ID_AT_START.matcher(text).find();
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
    this.inputStream = inputStream;
    this.options = options;

    if (!options.containsKey(E_PACKAGE_OPTION)) {
      throw new Error("Missing option 'ePackage' with EPackage object.");
    }

    P21ParserListener listener = init((EPackage) options.get(E_PACKAGE_OPTION));

    try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream))) {

      long start = System.currentTimeMillis();
      System.out.println("Start ...");

      br.lines().filter(P21LoadImpl::startsWithEntityId).collect(Collectors.toList()).forEach(line -> parse(line, listener));

      System.out.println("Finished in " + (System.currentTimeMillis() - start) + " ms");
      resource.getContents().add(listener.data());
    }
  }

  public final void processLineByLine(InputStream inputStream) throws IOException
  {
    try (Scanner scanner = new Scanner(inputStream)) {
      while (scanner.hasNextLine()) {
        processLine(scanner.nextLine());
      }
    }
  }

  protected void processLine(String aLine)
  {
    //use a second Scanner to parse the content of each line 
    try (Scanner scanner = new Scanner(aLine)) {
      scanner.useDelimiter("=");
      if (scanner.hasNext()) {
        //assumes the line has a certain structure
        String name = scanner.next();
        String value = scanner.next();
        System.out.println("Name is : " + name.trim() + ", and Value is : " + value.trim());
      } else {
        System.out.println("Empty or invalid line. Unable to process.");
      }
    }
  }

  private P21ParserListener init(EPackage ePackage)
  {
    // setup needed ecore classes
    //
    EFactory eFactory = ePackage.getEFactoryInstance();
    EClass entitiesContainer = (EClass) ePackage.getEClassifiers().get(1);

    StepToModel stepToModel = new StepToModelImpl(eFactory, entitiesContainer);
    return new P21ParserListener(stepToModel);
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
      tree = parser.entityInstance();
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

        tree = parser.entityInstance();
      }
    }

    ParseTreeWalker walker = new ParseTreeWalker();
    walker.walk(listener, tree);
  }
}
