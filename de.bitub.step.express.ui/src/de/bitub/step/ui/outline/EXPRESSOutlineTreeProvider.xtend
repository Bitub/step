/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 *  Sebastian Riemschüssel - add documentation and SelectType Outline Label
 */

package de.bitub.step.ui.outline

import com.google.inject.Inject
import de.bitub.step.express.Attribute
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.CollectionType
import de.bitub.step.express.Entity
import de.bitub.step.express.EnumType
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import org.eclipse.jface.viewers.StyledString
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.FontData
import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.ui.editor.outline.IOutlineNode
import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider
import org.eclipse.xtext.ui.editor.utils.TextStyle
import org.eclipse.xtext.ui.label.StylerFactory
import de.bitub.step.express.LiteralType

/**
 * Customization of the default outline structure.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#outline
 */
class EXPRESSOutlineTreeProvider extends DefaultOutlineTreeProvider {

	@Inject
	private StylerFactory stylerFactory;

	/**
	 * Create all child nodes of Entity for outline view.  
	 */
	def void _createChildren(IOutlineNode parentNode, Entity e) {

		e.disjointSubtype.forEach[entity|createNode(parentNode, entity)];
		e.attributes.forEach[attribute|createNode(parentNode, attribute)];
	}

	/**
	 * Create child nodes of type for outline view.
	 */
	def void _createChildren(IOutlineNode parentNode, Type e) {

		// display all types and entities of the select as child nodes in outline
		//
		if (e.datatype instanceof SelectType) {
			(e.datatype as SelectType).select.forEach[s|createNode(parentNode, s)]
		}

		// display all literals of enum as child nodes in outline
		//
		if (e.datatype instanceof EnumType) {
			(e.datatype as EnumType).literals.forEach[term|createNode(parentNode, term)];
		}
	}

	/**
	 * Styled string for enum literal. 
	 */
	def Object _text(LiteralType t) {
		val StyledString s = new StyledString("Literal",
			stylerFactory.createXtextStyleAdapterStyler(typeTextStyleIndication(9)));

		s.append(" " + t.name)
	}

	/**
	 * Styled string for enitity.
	 */
	def Object _text(Entity e) {
		val StyledString s = new StyledString(if(e.abstract) "Abstract entity" else "Entity",
			stylerFactory.createXtextStyleAdapterStyler(typeTextStyleIndication(9)));
		s.append(" " + e.name + " ");

		val StringBuilder str = new StringBuilder();
		for (Entity t : e.supertype) {
			str.append(t.name + ",");
		}
		s.append(
			if(str.length > 0) " : " + str.substring(0, str.length - 1) else "",
			stylerFactory.createXtextStyleAdapterStyler(typeTextStyleDecoration(9))
		);
		return s;
	}

	/**
	 * Styled string for EnumType, SelectType and Type.
	 */
	def Object _text(Type e) {

		val type = switch e.datatype {
			EnumType: "Enum"
			SelectType: "Select"
			CollectionType: "Type : "+ e.datatype.nameOf
			default: "Type"
		}

		val StyledString s = new StyledString(type,
			stylerFactory.createXtextStyleAdapterStyler(typeTextStyleIndication(9)));
		s.append(" " + e.name);

		return s;
	}

	/**
	 * Styled string for attributes (derived, inverse, optional or normal).  
	 */
	def Object _text(Attribute a) {

		val StyledString s = new StyledString(if (a.expression != null)
			"derived "
		else
			"" + if (a.opposite != null)
				"inverse "
			else
				"" + if(a.optional) "optional " else "",
			stylerFactory.createXtextStyleAdapterStyler(typeTextStyleIndication(8)));

		s.append(nameOf(a));
		return s;
	}

	// NAME OF ...
	def dispatch String nameOf(ReferenceType e) {
		e.instance.name;
	}

	def dispatch String nameOf(Type e) {
		e.name;
	}

	def dispatch String nameOf(Entity e) {
		e.name;
	}

	def dispatch String nameOf(Attribute e) {
		e.name + " : " + nameOf(e.type);
	}

	def dispatch String nameOf(CollectionType e) {
		e.name + " of " + nameOf(e.type);
	}

	def dispatch String nameOf(BuiltInType e) {
		e.eClass.name;
	}

	// END NAME OF ...
	def protected TextStyle typeTextStyleDecoration(int pointSize) {

		val TextStyle style = new TextStyle();
		style.color = new RGB(149, 125, 71);
		style.fontData = new FontData("Arial", pointSize, SWT.NORMAL);
		return style;
	}

	def protected TextStyle typeTextStyleIndication(int pointSize) {

		val TextStyle style = new TextStyle();
		style.color = new RGB(125, 149, 71);
		style.style = SWT.BOLD;
		style.fontData = new FontData("Arial", pointSize, SWT.BOLD);
		return style;
	}

}
