package de.bitub.step.p21.ui.editors;

import org.eclipse.emf.ecore.presentation.EcoreEditor;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.editors.text.TextEditor;

public class P21MultiPageEditor extends EcoreEditor
{
  TextEditor editor = null;

  public P21MultiPageEditor()
  {
    super();
  }

  @Override
  public void createPages()
  {
    super.createPages();
    addP21Viewer();
  }

  void addP21Viewer()
  {
//    Composite composite = new Composite(getContainer(), SWT.NONE);
    try {
      editor = new P21SourceEditor();
      int index = addPage(editor, getEditorInput());
      setPageText(index, editor.getTitle());
    }
    catch (PartInitException e) {
      e.printStackTrace();
    }
  }
}
