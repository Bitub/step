package de.bitub.step.p21.concurrrent;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.bitub.step.p21.StepUntypedToEcore;

public class P21ResolveReferencesTask implements Runnable
{

  private EStructuralFeature feature;
  private EObject entity;
  private EObject resolvedEntity;

  public P21ResolveReferencesTask(EStructuralFeature feature, EObject entity, EObject resolvedEntity)
  {
    this.feature = feature;
    this.entity = entity;
    this.resolvedEntity = resolvedEntity;
  }

  @Override
  public void run()
  {
    StepUntypedToEcore.connectEntityWithResolvedReference(feature, entity, resolvedEntity);
  }

}
