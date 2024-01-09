extension Swiftinit
{
    enum Bias
    {
        case culture(Unidoc.Scalar)
        case neutral
    }
}
extension Swiftinit.Bias
{
    var edition:Unidoc.Edition?
    {
        switch self
        {
        case .culture(let culture): return culture.edition
        case .neutral:              return nil
        }
    }
}
