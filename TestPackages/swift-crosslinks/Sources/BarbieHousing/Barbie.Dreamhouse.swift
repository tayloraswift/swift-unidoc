import BarbieCore

extension Barbie
{
    /// We can reference the ``ID`` type from here, even though we are in a
    /// different module, because `Dreamhouse` is nested in the ``Barbie``
    /// namespace. We can also refer to it as ``Barbie.ID``, or
    /// ``BarbieCore.Barbie.ID``.
    public
    enum Dreamhouse
    {
    }
}
