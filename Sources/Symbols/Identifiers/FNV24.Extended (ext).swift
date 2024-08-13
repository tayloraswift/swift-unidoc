import FNV1

extension FNV24.Extended
{
    @inlinable public
    static func decl(_ symbol:Symbol.Decl.Vector) -> Self
    {
        .init(hashing: "\(symbol)")
    }
    @inlinable public
    static func decl(_ symbol:Symbol.Decl) -> Self
    {
        //  No added prefix, as ``Symbol.Decl.description`` already includes a `s:` prefix.
        .init(hashing: "\(symbol)")
    }

    @inlinable public
    static func module(_ symbol:Symbol.Module) -> Self
    {
        .init(hashing: "s:m:\(symbol)")
    }
    @inlinable public
    static func product(_ name:String) -> Self
    {
        //  Not the ``Symbol.Product``!
        .init(hashing: "s:p:\(name)")
    }
}
