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
import java.util.Map;

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

import de.bitub.step.p21.P21ParserListener;
import de.bitub.step.p21.StepLexer;
import de.bitub.step.p21.StepParser;

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

    CharStream input = new ANTLRInputStream(this.inputStream);
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

      tree = parser.exchangeFile();
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
    P21ParserListener listener = new P21ParserListener();

    walker.walk(listener, tree);

    resource.getContents().add(listener.getContainer());
  }

}
