extension UnidocPlane
{
    @frozen public
    enum Topic:UnidocPlaneType
    {
        @inlinable public static
        var plane:UnidocPlane { .topic }
    }
}
