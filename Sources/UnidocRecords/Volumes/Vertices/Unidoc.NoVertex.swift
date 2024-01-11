extension Unidoc
{
    /// A vertex that is missing from the database. This type is useful because unlike ``Void``
    /// or `Never?`, it is ``Identifiable``.
    @frozen public
    enum NoVertex:Equatable, Sendable
    {
        case missing
    }
}
extension Unidoc.NoVertex:Identifiable
{
    @inlinable public
    var id:Never? { nil }
}
