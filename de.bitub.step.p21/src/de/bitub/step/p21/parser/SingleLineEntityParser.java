package de.bitub.step.p21.parser;

import java.util.Objects;

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
import org.eclipse.emf.ecore.EObject;

import de.bitub.step.p21.StepLexer;
import de.bitub.step.p21.StepParser;

public class SingleLineEntityParser
{
  public EObject parse(String line, P21EntityListener listener)
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
      ex.printStackTrace();
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

    // could not parse subtree -> result is tree being null
    //
    if (Objects.nonNull(tree)) {
      ParseTreeWalker walker = new ParseTreeWalker();
      try {
        walker.walk(listener, tree);
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    } else {

      // TODO report unhandled lines
      System.out.println("Could not parse: " + line);
    }

    return listener.entity();
  }
}
