package org.buildingsmart.mvd.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;

public class EditorUtils {

	public static List<IProject> getProjects() {
		return Arrays.asList(ResourcesPlugin.getWorkspace().getRoot().getProjects());
	}

	public static List<IFile> getAllIfcFilesInProject(IProject project) {
		List<String> extensions = new ArrayList<>(Arrays.asList(".ifc"));
		return getAllFilesWithExtensionsInProject(extensions, project);
	}

	public static List<IFile> getAllFilesWithExtensionsInProject(List<String> extensions, IProject project) {
		final List<IFile> files = new ArrayList<IFile>();

		try {
			project.accept(new IResourceVisitor() {

				@Override
				public boolean visit(IResource resource) throws CoreException {

					if ((resource.getType() & IResource.FILE) != 0) {

						for (String extension : extensions) {

							if (resource.getName().endsWith(extension)) {
								files.add((IFile) resource);
							}
						}
					}
					return true;
				}
			});
		} catch (CoreException e) {
			e.printStackTrace();
		}

		return files;
	}

	public static List<IFile> collectAllFilesWithExtension(String[] extensions) {
		List<IProject> projects = EditorUtils.getProjects();
		List<IFile> ifcFiles = new ArrayList<IFile>();

		for (IProject project : projects) {
			ifcFiles.addAll(EditorUtils.getAllFilesWithExtensionsInProject(Arrays.asList(extensions), project));
		}

		return ifcFiles;
	}

	public static List<IFile> getAllMvdFilesInProject(IProject project) {

		List<String> extensions = new ArrayList<>(Arrays.asList(".mvdxml", ".tmvd"));
		return getAllFilesWithExtensionsInProject(extensions, project);
	}
}
