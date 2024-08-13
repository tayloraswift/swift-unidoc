import BarbieCore

extension Barbie.Dreamhouse
{
    /// We can reference the <doc:ID> type from here, even though we are in a
    /// different module, because `Dreamhouse` is nested in the <doc:Barbie>
    /// namespace. We can also refer to it as <doc:Barbie/ID>, or
    /// <doc:BarbieCore/Barbie/ID>. As an optimization, Unidoc combines multiple
    /// occurrences of the same codelink, such as <doc:Barbie/ID>, into a single
    /// outline. We can also reference standard library types like <doc:Int>. And we can
    /// reference nested standard library types like <doc:Int/max>.
    public
    struct Keys
    {
    }
}
