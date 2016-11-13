package org.buildingsmart.mvd.commands;

import org.buildingsmart.ifc4.IFC4;
import org.buildingsmart.ifc4.Ifc4Package;
import org.buildingsmart.mvd.mvdxml.MvdXML;
import org.buildingsmart.mvd.mvdxml.util.IOHelper;
import org.buildingsmart.mvd.tmvd.analyzing.IfcModelChecker;
import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IHandler;
import org.eclipse.core.resources.IFile;
import org.eclipse.emf.common.util.URI;

public class ValidateIfcFileWithMvdRules extends AbstractHandler implements IHandler
{

  @Override
  public Object execute(ExecutionEvent event) throws ExecutionException
  {
    IFile mvdFile = (IFile) event.getParameters().get("org.buildingsmart.mvd.editor.commandParameter.mvdfile");
    MvdXML mvd = (MvdXML) IOHelper.loadMvdXML(mvdFile.getFullPath().toString());

    IFile ifcFile = (IFile) event.getParameters().get("org.buildingsmart.mvd.editor.commandParameter.ifcfile");
    IFC4 model =
        (IFC4) de.bitub.step.p21.util.IOHelper.load(URI.createURI(ifcFile.getFullPath().toString()), Ifc4Package.eINSTANCE);

    IfcModelChecker checker = new IfcModelChecker(model, mvd);
    checker.checkAll();

    // TODO enable if merged
//    QueryIfc viatra = new QueryIfc();
//    viatra.test(model);
//    URI patternURI = URI.createURI("platform:/plugin/test/src/test/query.vql");
//
//    String result = viatra.executePattern_LoadFromVQL(model, patternURI, "test.isApplicable");
//    System.out.println(result);
//
//    result = viatra.executePattern_LoadFromVQL(model, patternURI, "test.propertySetsForObjects");
//    System.out.println(result);
    return null;
  }
}
