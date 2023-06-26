@available(*, deprecated, renamed: "Symbol.Block")
public
typealias BlockSymbol = Symbol.Block

extension Symbol
{
    @frozen public
    struct Block:Hashable, Equatable, Sendable
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
}
extension Symbol.Block:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "s:e:\(self.name)"
    }
}
extension Symbol.Block:LosslessStringConvertible
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
