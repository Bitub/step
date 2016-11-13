package org.buildingsmart.mvd.menu;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.buildingsmart.mvd.util.EditorUtils;
import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.NotEnabledException;
import org.eclipse.core.commands.NotHandledException;
import org.eclipse.core.commands.common.NotDefinedException;
import org.eclipse.core.resources.IFile;
import org.eclipse.jface.action.ContributionItem;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.ui.ISelectionService;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;
import org.eclipse.ui.handlers.IHandlerService;

public class IfcFileContributionItem extends ContributionItem {

	IWorkbenchWindow window = PlatformUI.getWorkbench().getActiveWorkbenchWindow();

	ISelectionService selectionService = window.getSelectionService();
	ICommandService commandService = window.getService(ICommandService.class);
	IHandlerService handlerService = window.getService(IHandlerService.class);

	public IfcFileContributionItem() {

	}

	public IfcFileContributionItem(String id) {
		super(id);
	}

	@Override
	public void fill(Menu menu, int index) {
		ISelection selection = selectionService.getSelection();
		if (selection instanceof IStructuredSelection) {
			IStructuredSelection structuredSelection = (IStructuredSelection) selection;
			IFile mvdFile = (IFile) structuredSelection.getFirstElement();

			List<IFile> ifcFiles = EditorUtils.collectAllFilesWithExtension(new String[] { ".ifc" });

			for (IFile ifcFile : ifcFiles) {
				MenuItem menuItem = new MenuItem(menu, SWT.CHECK, index);
				menuItem.setText("IFC-File (" + ifcFile.getName() + ")");
				menuItem.setData("FILE", ifcFile);

				menuItem.addSelectionListener(new SelectionAdapter() {
					public void widgetSelected(SelectionEvent e) {
						executeValidation(mvdFile, (IFile) e.widget.getData("FILE"));
					}
				});
			}
		}
	}

	private void executeValidation(IFile mvdFile, IFile ifcFile) {

		String commandId = "org.buildingsmart.mvd.editor.command.validateifc";
		Command validateIFC = commandService.getCommand(commandId);

		Map<String, IFile> params = new HashMap<String, IFile>();
		params.put("org.buildingsmart.mvd.editor.commandParameter.ifcfile", ifcFile);
		params.put("org.buildingsmart.mvd.editor.commandParameter.mvdfile", mvdFile);

		try {

			validateIFC.executeWithChecks(new ExecutionEvent(validateIFC, params, null, null));

		} catch (NotDefinedException | ExecutionException | NotEnabledException | NotHandledException e) {
			e.printStackTrace();
		}

	}
}
