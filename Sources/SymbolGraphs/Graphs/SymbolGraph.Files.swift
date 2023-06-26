import Unidoc

extension SymbolGraph
{
    @frozen public
    enum Files:UnidocPlaneType
    {
        @inlinable public static
        var plane:UnidocPlane { .file }
    }
}
