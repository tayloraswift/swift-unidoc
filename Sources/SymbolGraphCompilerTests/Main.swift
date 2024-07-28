import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        DefaultImplementations.self,
        FeatureInheritance.self,
        ExternalExtensionsWithConformances.self,
        ExternalExtensionsWithConstraints.self,
        InternalExtensionsWithConformances.self,
        InternalExtensionsWithConstraints.self,
    ]
}
