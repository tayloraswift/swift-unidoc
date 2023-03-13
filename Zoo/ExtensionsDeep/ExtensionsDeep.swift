import ZooExtensions

extension Int.OuterIntExtension
{
    public
    enum InnerIntExtension
    {
    }
}

extension Optional.OuterOptionalExtension
{
    public
    enum InnerOptionalExtension
    {
    }
}

extension Optional.OuterOptionalIntExtension
{
    public
    enum InnerOptionalIntExtension
    {
    }
}

extension Optional<Int>:Identifiable
{
    /// doc doc doc
    public
    var id:Never { fatalError() }
}
extension Optional<Int>:Sendable, Error
{
}
