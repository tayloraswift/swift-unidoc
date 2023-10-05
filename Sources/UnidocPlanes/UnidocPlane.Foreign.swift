extension UnidocPlane
{
    @frozen public
    enum Foreign:UnidocPlaneType
    {
        @inlinable public static
        var plane:UnidocPlane { .foreign }
    }
}
