import BarbieCore

extension Barbie
{
    /// We can reference the ``ID`` type from here, even though we are in a
    /// different module, because `Dreamhouse` is nested in the ``Barbie``
    /// namespace. We can also refer to it as ``Barbie.ID``, or
    /// ``BarbieCore.Barbie.ID``. As an optimization, Unidoc combines multiple
    /// occurrences of the same codelink, such as ``Barbie.ID``, into a single
    /// outline. We can also reference standard library types like ``Int``.
    public
    enum Dreamhouse
    {
    }
}
extension Barbie.Dreamhouse
{
    /// The keys to this dreamhouse.
    public
    var keys:Keys { .init() }
}
