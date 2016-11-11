package de.bitub.step.p21.ui.editors;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.presentation.IPresentationReconciler;
import org.eclipse.jface.text.presentation.PresentationReconciler;
import org.eclipse.jface.text.rules.DefaultDamagerRepairer;
import org.eclipse.jface.text.rules.IRule;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.ITokenScanner;
import org.eclipse.jface.text.rules.MultiLineRule;
import org.eclipse.jface.text.rules.PatternRule;
import org.eclipse.jface.text.rules.RuleBasedScanner;
import org.eclipse.jface.text.rules.SingleLineRule;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.SourceViewerConfiguration;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;

public class P21SourceViewerConfiguration extends SourceViewerConfiguration
{

  @Override
  public IPresentationReconciler getPresentationReconciler(ISourceViewer sourceViewer)
  {
    PresentationReconciler reconciler = new PresentationReconciler();
    DefaultDamagerRepairer dflt = new DefaultDamagerRepairer(createTokenScanner());
    reconciler.setDamager(dflt, IDocument.DEFAULT_CONTENT_TYPE);
    reconciler.setRepairer(dflt, IDocument.DEFAULT_CONTENT_TYPE);
    return reconciler;
  }

  private ITokenScanner createTokenScanner()
  {
    RuleBasedScanner scanner = new RuleBasedScanner();
    scanner.setRules(createRules());
    return scanner;
  }

  private IRule[] createRules()
  {

    IToken boldGreen = new Token(new TextAttribute(getGreenColor(), null, SWT.BOLD));
    IToken blue = new Token(new TextAttribute(getBlueColor()));
    IToken gray = new Token(new TextAttribute(getGrayColor()));
    IToken green = new Token(new TextAttribute(getGreenColor()));

    return new IRule[] { new EntityIdRule(boldGreen), new SingleLineRule("'", "'", blue, '\\'),
        new MultiLineRule("/*", "*/", gray), new PatternRule("#", "", blue, '\\', false) };
  }

  private Color getGreenColor()
  {
    return new Color(null, new RGB(0, 128, 0));
  }

  private Color getGrayColor()
  {
    return new Color(null, new RGB(128, 128, 128));
  }

  private Color getBlueColor()
  {
    return new Color(null, new RGB(0, 0, 255));
  }
}
