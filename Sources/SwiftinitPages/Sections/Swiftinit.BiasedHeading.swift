extension Swiftinit
{
    typealias BiasedHeading = _SwiftinitBiasedHeading
}

protocol _SwiftinitBiasedHeading
{
    static func citizens(in culture:Unidoc.Scalar) -> Self
    static func available(in culture:Unidoc.Scalar) -> Self
    static func `extension`(in culture:Unidoc.Scalar) -> Self
}

extension Swiftinit.BiasedHeading
{
    init(culture:Unidoc.Scalar, bias:Unidoc.Bias)
    {
        if  case .culture(culture) = bias
        {
            self = .citizens(in: culture)
        }
        else if case culture.edition? = bias.edition
        {
            self = .available(in: culture)
        }
        else
        {
            self = .extension(in: culture)
        }
    }
}
