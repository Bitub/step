package de.bitub.step.p21.ui.editors;

import org.eclipse.ui.editors.text.TextEditor;

public class P21SourceEditor extends TextEditor
{

  @Override
  protected void initializeEditor()
  {
    super.initializeEditor();
    setSourceViewerConfiguration(new P21SourceViewerConfiguration());
  }

}
