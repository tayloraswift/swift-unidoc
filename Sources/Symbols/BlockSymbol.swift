@frozen public
struct BlockSymbol:Hashable, Equatable, Sendable
{
    /// The name of this extension block, without the `s:e:` prefix.
    /// An extension block name can include any colons and special characters.
    public
    let name:String

    @inlinable public
    init(name:String)
    {
        self.name = name
    }
}
extension BlockSymbol:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "s:e:\(self.name)"
    }
}
extension BlockSymbol:LosslessStringConvertible
{
    public
    init?(_ description:__shared String)
    {
        if  let index:String.Index = description.index(description.startIndex,
                offsetBy: 4,
                limitedBy: description.endIndex),
            description.starts(with: "s:e:")
        {
            self.init(name: .init(description.suffix(from: index)))
        }
        else
        {
            return nil
        }
    }
}
