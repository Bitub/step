package de.bitub.step.p21.concurrrent;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.bitub.step.p21.StepUntypedToEcore;

public class P21ResolveReferencesListTask implements Runnable
{

  private EStructuralFeature feature;
  private EObject wrapper;
  private List<EObject> resolvedEntities;

  public P21ResolveReferencesListTask(EStructuralFeature feature, EObject wrapper, List<EObject> resolvedEntities)
  {
    this.feature = feature;
    this.wrapper = wrapper;
    this.resolvedEntities = resolvedEntities;
  }

  @Override
  public void run()
  {
    StepUntypedToEcore.connectListWrapperWithUnresolvedReferences(feature, wrapper, resolvedEntities);
  }
}
