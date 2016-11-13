/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */

package de.bitub.step.ui.views;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Stack;

import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.viewers.IColorProvider;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.ViewPart;
import org.eclipse.zest.core.viewers.EntityConnectionData;
import org.eclipse.zest.core.viewers.GraphViewer;
import org.eclipse.zest.core.viewers.IGraphEntityContentProvider;
import org.eclipse.zest.core.widgets.ZestStyles;
import org.eclipse.zest.layouts.algorithms.TreeLayoutAlgorithm;

import de.bitub.step.express.Attribute;
import de.bitub.step.express.CollectionType;
import de.bitub.step.express.DataType;
import de.bitub.step.express.Entity;
import de.bitub.step.express.ReferenceType;
import de.bitub.step.express.Schema;

public class EXPRESSInheritanceGraphViewPart extends ViewPart
{
  private GraphViewer m_zestViewer;

  class EntityHierarchyContentProvider implements IGraphEntityContentProvider
  {

    List<Entity> entities = new ArrayList<>();
    List<Attribute> attributes = new ArrayList<>();

    @Override
    public void dispose()
    {
      entities.clear();
      attributes.clear();
    }

    @Override
    public void inputChanged(Viewer viewer, Object oldInput, Object newInput)
    {
      entities.clear();
      attributes.clear();

      if (newInput instanceof Object[]) {

        List<Entity> input = getInput((Object[]) newInput);
        if (!input.isEmpty() && 2 > input.size()) {
          collectSuperTypes(input.get(0), entities, attributes);
        } else {

          entities.addAll(input);
        }
      } else {

        if (newInput != null) {
          throw new IllegalArgumentException();
        }
      }
    }

    private List<Entity> getInput(Object[] input)
    {
      List<Entity> elements = new ArrayList<>();
      for (Object o : input) {

        if (o instanceof Entity) {

          elements.add((Entity) o);
        }

        if (o instanceof Schema) {

          elements.addAll(((Schema) o).getEntity());
        }
      }
      return elements;
    }

    private void collectSuperTypes(Entity rootEntity, List<Entity> superTypeList, List<Attribute> attributeList)
    {
      Stack<Entity> dfsStack = new Stack<Entity>();
      Set<Entity> doneSet = new HashSet<>();
      dfsStack.push(rootEntity);

      while (!dfsStack.isEmpty()) {

        Entity entity = dfsStack.peek();
        if (doneSet.contains(entity)) {

          dfsStack.removeElementAt(dfsStack.size() - 1);
        }

        boolean isVisited = true;
        for (Entity superType : entity.getSupertype()) {

          // If there's an entity which has not been left
          if (!doneSet.contains(superType)) {
            dfsStack.push(superType);
            isVisited = false;
          }
        }

        if (isVisited) {

          dfsStack.removeElementAt(dfsStack.size() - 1);
          attributeList.addAll(entity.getAttribute());
          superTypeList.add(entity);

          doneSet.add(entity);
        }
      }
    }

    @Override
    public Object[] getElements(Object inputElement)
    {
      return entities.toArray();
    }

    @Override
    public Object[] getConnectedTo(Object object)
    {
      List<Object> targetList = new ArrayList<>();
      if (object instanceof Entity) {

        targetList.addAll(((Entity) object).getSupertype());

        if (object.equals(entities.get(entities.size() - 1))) {

          targetList.addAll(attributes);
        }
      }

      if (object instanceof Attribute) {

        targetList.add(((Attribute) object).getType());
      }
      return targetList.toArray();
    }
  }

  /**
   * <!-- begin-user-doc -->
   * Label provider for entities and attributes.
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @author bernold - 07.12.2014
   */
  class EntitySubTypeRelationLabeProvider extends LabelProvider implements IColorProvider
  {
    @Override
    public String getText(Object element)
    {
      if (element instanceof Entity) {

        return ((Entity) element).getName();
      }
      if (element instanceof Attribute) {

        return ((Attribute) element).getName();
      }

      if (element instanceof DataType) {
        if (element instanceof CollectionType) {

          DataType refType = ((CollectionType) element).getType();
          return ((CollectionType) element).getName() + " of " + (refType instanceof ReferenceType
              ? ((ReferenceType) refType).getInstance().getName() : refType.eClass().getName());
        }

        return ((DataType) element).eClass().getName();
      }

      if (element instanceof EntityConnectionData) {
        if (((EntityConnectionData) element).dest instanceof Attribute) {

          Attribute a = (Attribute) ((EntityConnectionData) element).dest;
          return (a.getOpposite() != null ? "inverse " : "") + "host for"; //$NON-NLS-1$ //$NON-NLS-2$

        }
        if (((EntityConnectionData) element).source instanceof Attribute) {

          return "as"; //$NON-NLS-1$

        } else {

          return "subtype of"; //$NON-NLS-1$
        }
      }
      return super.getText(element);
    }

    @Override
    public Color getForeground(Object element)
    {
      if (element instanceof Attribute) {
        return Display.getDefault().getSystemColor(SWT.COLOR_BLACK);
      }

      return null;
    }

    @Override
    public Color getBackground(Object element)
    {
      if (element instanceof Attribute) {
        return Display.getDefault().getSystemColor(SWT.COLOR_GRAY);
      }

      return null;
    }
  }

  /**
   * The global selection listener.
   */
  private ISelectionListener m_selectionListener = new ISelectionListener() {

    @Override
    public void selectionChanged(IWorkbenchPart part, ISelection selection)
    {
      if (getSite().getPart().equals(part)) {
        return;
      }

      if (selection instanceof IStructuredSelection) {

        List<EObject> list = new ArrayList<>();
        for (Object o : ((IStructuredSelection) selection).toArray()) {

          EObject object = Platform.getAdapterManager().getAdapter(o, EObject.class);
          if (null != object) {
            list.add(object);
          }
        }

        m_zestViewer.setInput(list.toArray());
      }
    }
  };

  @Override
  public void createPartControl(Composite parent)
  {
    parent.setLayout(new FillLayout());
    m_zestViewer = new GraphViewer(parent, SWT.NONE);
    m_zestViewer.setNodeStyle(ZestStyles.NODES_NO_LAYOUT_RESIZE);
    m_zestViewer.setConnectionStyle(ZestStyles.CONNECTIONS_DIRECTED);
    m_zestViewer.setContentProvider(new EntityHierarchyContentProvider());
    m_zestViewer.setLabelProvider(new EntitySubTypeRelationLabeProvider());
    m_zestViewer.setLayoutAlgorithm(new TreeLayoutAlgorithm());
    //m_zestViewer.setLayoutAlgorithm(new SpringLayoutAlgorithm());

    PlatformUI.getWorkbench().getActiveWorkbenchWindow().getSelectionService().addSelectionListener(m_selectionListener);
  }

  @Override
  public void setFocus()
  {
    m_zestViewer.getControl().setFocus();
  }

  @Override
  public void dispose()
  {
    if (!PlatformUI.getWorkbench().isClosing()) {

      PlatformUI.getWorkbench().getActiveWorkbenchWindow().getSelectionService().removeSelectionListener(m_selectionListener);
    }
    super.dispose();
  }

}
