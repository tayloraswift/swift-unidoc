import BSON

extension Unidoc
{
    /// A type that encodes itself as an explicit ``BSON.AnyValue/null`` if it is representing
    /// the default group layer.
    @frozen public
    struct GroupLayerPredicate
    {
        public
        let layer:GroupLayer?

        @inlinable public
        init(_ layer:GroupLayer?)
        {
            self.layer = layer
        }
    }
}
extension Unidoc.GroupLayerPredicate
{
    @inlinable public static
    var protocols:Self { .init(.protocols) }

    @inlinable public static
    var `default`:Self { .init(nil) }
}
extension Unidoc.GroupLayerPredicate:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.FieldEncoder)
    {
        //  NO optional chaining!
        self.layer.encode(to: &bson)
    }
}
