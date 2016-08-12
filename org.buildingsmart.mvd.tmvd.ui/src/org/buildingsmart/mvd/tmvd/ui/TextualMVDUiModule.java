/*
 * generated by Xtext
 */
package org.buildingsmart.mvd.tmvd.ui;

import org.buildingsmart.mvd.tmvd.ui.errormessages.TextualMvdSyntaxErrorMessageProvider;
import org.buildingsmart.mvd.tmvd.ui.hover.TextualMVDDocumentationProvider;
import org.buildingsmart.mvd.tmvd.ui.hover.TextualMVDHoverProvider;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider;
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider;
import org.eclipse.xtext.ui.editor.hover.IEObjectHoverProvider;

/**
 * Use this class to register components to be used within the IDE.
 */
public class TextualMVDUiModule extends org.buildingsmart.mvd.tmvd.ui.AbstractTextualMVDUiModule
{
  public TextualMVDUiModule(AbstractUIPlugin plugin)
  {
    super(plugin);
  }

  public Class<? extends ISyntaxErrorMessageProvider> bindISyntaxErrorMessageProvider()
  {
    return TextualMvdSyntaxErrorMessageProvider.class;
  }

  public Class<? extends IEObjectHoverProvider> bindIEObjectHoverProvider()
  {
    return TextualMVDHoverProvider.class;
  }

  public Class<? extends IEObjectDocumentationProvider> bindIEObjectDocumentationProviderr()
  {
    return TextualMVDDocumentationProvider.class;
  }

}