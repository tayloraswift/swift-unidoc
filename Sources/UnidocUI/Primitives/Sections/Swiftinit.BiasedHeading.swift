extension Unidoc
{
    protocol BiasedHeading
    {
        static func citizens(in culture:Unidoc.Scalar) -> Self
        static func available(in culture:Unidoc.Scalar) -> Self
        static func `extension`(in culture:Unidoc.Scalar) -> Self
    }
}
extension Unidoc.BiasedHeading
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
