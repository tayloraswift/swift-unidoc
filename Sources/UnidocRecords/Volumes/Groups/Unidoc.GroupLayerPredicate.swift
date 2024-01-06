import BSON

extension Unidoc
{
    /// A type that encodes itself as an explicit ``BSON.AnyValue/null`` if it is representing
    /// the default group layer.
    @frozen public
    struct GroupLayerPredicate:RawRepresentable
    {
        public
        let rawValue:GroupLayer?

        @inlinable public
        init(rawValue:GroupLayer?)
        {
            self.rawValue = rawValue
        }
    }
}
extension Unidoc.GroupLayerPredicate
{
    @inlinable public static
    var protocols:Self { .init(rawValue: .protocols) }

    @inlinable public static
    var `default`:Self { .init(rawValue: nil) }
}
extension Unidoc.GroupLayerPredicate:BSONEncodable
{
}
