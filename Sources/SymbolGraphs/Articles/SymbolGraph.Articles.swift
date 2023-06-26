import Unidoc

extension SymbolGraph
{
    @frozen public
    enum Articles:UnidocPlaneType
    {
        @inlinable public static
        var plane:UnidocPlane { .article }
    }
}
