package org.buildingsmart.mvd.mvdxml.resource;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.buildingsmart.mvd.mvdxml.AttributeRule;
import org.buildingsmart.mvd.mvdxml.ConceptTemplate;
import org.buildingsmart.mvd.mvdxml.Definitions;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.eclipse.emf.ecore.xmi.XMLResource.ResourceHandler;
import org.eclipse.emf.ecore.xmi.impl.BasicResourceHandler;

public class MvdXmlResourceHandler extends BasicResourceHandler implements ResourceHandler {

	private int i = 0;
	protected List<EObject> unnamedObjects = new ArrayList<EObject>();

	public void transform(XMLResource resource) {

		TreeIterator<EObject> iterator = EcoreUtil.getAllContents(resource, Boolean.TRUE);
		while (iterator.hasNext()) {
			EObject next = iterator.next();

			if (next instanceof Definitions) {
				removeDocumemtation((Definitions) next);
			}

			if (next instanceof AttributeRule) {
				AttributeRule attr = (AttributeRule) next;

				if (attr.getRuleID() != null) {

					if (attr.getRuleID().isEmpty()) {

						removeEmptyRuleIDs(attr);
					} else {

						removeWhiteSpacefromRuleID(attr);
					}
				}
			}

			if (next instanceof ConceptTemplate) {
				ConceptTemplate conceptTempl = (ConceptTemplate) next;

				if (conceptTempl.getName() != null) {
					removeWhiteSpacefromName(conceptTempl);
				}
			}

			removeNullOrEmptyCodes(next);
			fillNullOrEmptyName(next);
		}

	}

	private void fillNullOrEmptyName(EObject next) {
		EStructuralFeature nameFeature = next.eClass().getEStructuralFeature("name");
		if (null != nameFeature) {
			String name = (String) next.eGet(nameFeature);

			if (name.isEmpty()) {
				name = next.eClass().getName() + "_" + (i++);
				next.eSet(nameFeature, name);
				unnamedObjects.add(next);
			}
		}

	}

	private void removeNullOrEmptyCodes(EObject next) {

		EStructuralFeature codeFeature = next.eClass().getEStructuralFeature("code");
		if (null != codeFeature) {
			String code = (String) next.eGet(codeFeature);

			if (null == code || code.isEmpty()) {
				next.eUnset(codeFeature);
			}
		}
	}

	@Override
	public void preSave(XMLResource resource, OutputStream outputStream, Map<?, ?> options) {
		transform(resource);
	}

	@Override
	public void postLoad(XMLResource resource, InputStream inputStream, Map<?, ?> options) {
		transform(resource);
	}

	private void removeDocumemtation(Definitions definitions) {
		EcoreUtil.remove(definitions);
	}

	private void removeEmptyRuleIDs(AttributeRule next) {
		EcoreUtil.remove(next, next.eClass().getEStructuralFeature("ruleID"), next.getRuleID());
	}

	private void removeWhiteSpacefromRuleID(AttributeRule next) {
		String ruleIdWithoutWhiteSpace = next.getRuleID().replaceAll("\\s", "");
		EcoreUtil.replace(next, next.eClass().getEStructuralFeature("ruleID"), next.getRuleID(),
				ruleIdWithoutWhiteSpace);
	}

	private void removeWhiteSpacefromName(ConceptTemplate next) {
		
		String ruleIdWithoutWhiteSpace = next.getName().replaceAll("\\s", "");
		EcoreUtil.replace(next, next.eClass().getEStructuralFeature("name"), next.getName(), ruleIdWithoutWhiteSpace);
	}
}
