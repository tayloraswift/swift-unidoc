import Testing_

@main enum Main: TestMain {
    static let all: [any TestBattery.Type] = [
        Determinism.self,
        DefaultImplementations.self,
        FeatureInheritance.self,
        FeatureInheritanceAccessControl.self,
        ExternalExtensionsWithConformances.self,
        ExternalExtensionsWithConstraints.self,
        InternalExtensionsWithConformances.self,
        InternalExtensionsWithConstraints.self,
    ]
}
