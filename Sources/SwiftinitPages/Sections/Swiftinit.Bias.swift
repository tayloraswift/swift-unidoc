extension Swiftinit
{
    enum Bias
    {
        case culture(Unidoc.Scalar)
        case neutral
        case package
    }
}
extension Swiftinit.Bias
{
    var edition:Unidoc.Edition?
    {
        switch self
        {
        case .culture(let culture): culture.edition
        case .neutral:              nil
        case .package:              nil
        }
    }
}
