import PackageGraphs

extension TargetNode
{
    enum DependencyError:Error
    {
        case undefinedNominal(String)
    }
}
