package org.buildingsmart.mvd.commands;

import org.buildingsmart.mvd.tmvd.util.IOHelper;
import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IHandler;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;

public class MVD2TextualMVDGenerationHandler extends AbstractHandler implements IHandler
{
  IOHelper io = new IOHelper();

  @Override
  public Object execute(ExecutionEvent event) throws ExecutionException
  {
    ISelection selection = HandlerUtil.getCurrentSelection(event);
    if (selection instanceof IStructuredSelection) {
      IStructuredSelection structuredSelection = (IStructuredSelection) selection;
      Object firstElement = structuredSelection.getFirstElement();

      if (firstElement instanceof IFile) {
        IFile file = (IFile) firstElement;
        IPath mvdXmlFilePath = file.getFullPath();

        // retrieve instance from selection
        // 
        EObject mvdInstance = io.loadMvdXML(mvdXmlFilePath.toString());

        // prepare new path
        IPath tMVDFilePath = mvdXmlFilePath.removeFileExtension();
        String fileName = tMVDFilePath.lastSegment();
        tMVDFilePath = tMVDFilePath.removeLastSegments(2);
        tMVDFilePath = tMVDFilePath.append("tmvd");
        tMVDFilePath = tMVDFilePath.append(fileName);
        tMVDFilePath = tMVDFilePath.addFileExtension("tmvd");

        // store into file
        //
        io.storeAsTMVD(mvdInstance, tMVDFilePath.toString());
      }
    }
    return null;
  }

}
