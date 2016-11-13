package org.buildingsmart.mvd.menu;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.buildingsmart.mvd.util.EditorUtils;
import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
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

public class MvdFileContributionItem extends ContributionItem {

	IWorkbenchWindow window = PlatformUI.getWorkbench().getActiveWorkbenchWindow();

	ISelectionService selectionService = window.getSelectionService();
	ICommandService commandService = window.getService(ICommandService.class);

	public MvdFileContributionItem() {
	}

	public MvdFileContributionItem(String id) {
		super(id);
	}

	@Override
	public void fill(Menu menu, int index) {
		ISelection selection = selectionService.getSelection();
		if (selection instanceof IStructuredSelection) {
			IStructuredSelection structuredSelection = (IStructuredSelection) selection;
			IFile ifcFile = (IFile) structuredSelection.getFirstElement();

			List<IFile> mvdFiles = EditorUtils.collectAllFilesWithExtension(new String[] { ".mvdxml" }); // add .tmvd

			for (IFile mvdFile : mvdFiles) {
				MenuItem menuItem = new MenuItem(menu, SWT.CHECK, index);
				menuItem.setText("MVD-File (" + mvdFile.getName() + ")");
				menuItem.setData("FILE", mvdFile);

				menuItem.addSelectionListener(new SelectionAdapter() {
					public void widgetSelected(SelectionEvent e) {
						executeValidation((IFile) e.widget.getData("FILE"), ifcFile);
					}
				});
			}
		}
	}

	private void executeValidation(IFile mvdFile, IFile ifcFile) {
		Command validationCommand = commandService.getCommand("org.buildingsmart.mvd.editor.command.validateifc");

		Map<String, IFile> params = new HashMap<String, IFile>();
		params.put("org.buildingsmart.mvd.editor.commandParameter.ifcfile", ifcFile);
		params.put("org.buildingsmart.mvd.editor.commandParameter.mvdfile", mvdFile);

		try {
			validationCommand.executeWithChecks(new ExecutionEvent(validationCommand, params, null, null));
		} catch (Exception exception) {
			exception.printStackTrace();
			System.err.println("Could not execute validation!");
		}
	}

}
