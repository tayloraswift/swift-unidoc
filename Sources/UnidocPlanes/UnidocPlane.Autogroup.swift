extension UnidocPlane
{
    @frozen public
    enum Autogroup:UnidocPlaneType
    {
        @inlinable public static
        var plane:UnidocPlane { .autogroup }
    }
}
