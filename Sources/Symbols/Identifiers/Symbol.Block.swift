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
extension Symbol.Block:Comparable
{
    @inlinable public
    static func < (a:Self, b:Self) -> Bool { a.name < b.name }
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
        guard case .block(let block)? = Symbol.USR.init(description)
        else
        {
            return nil
        }

        self = block
    }
}
