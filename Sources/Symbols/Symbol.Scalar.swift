import Symbolics

extension Symbol
{
    /// A scalar symbol resolution. The only difference between a resolution
    /// and a ``ScalarIdentifier`` is a symbol resolution contains a colon
    /// after its language prefix, like `s:s17FloatingPointSignO`.
    @frozen public
    struct Scalar:Equatable, Hashable, Sendable
    {
        public
        let id:ScalarIdentifier

        @inlinable public
        init(_ id:ScalarIdentifier)
        {
            self.id = id
        }
    }
}
extension Symbol.Scalar:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.id < rhs.id
    }
}
extension Symbol.Scalar:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.id.language):\(self.id.suffix)"
    }
}
extension Symbol.Scalar:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:__shared String)
    {
        self.init(fragments: description.split(separator: ":", maxSplits: 1,
            omittingEmptySubsequences: false))
    }
    @inlinable internal
    init?(fragments:__shared [Substring])
    {
        if  fragments.count == 2,
            let language:Unicode.Scalar = .init(fragments[0]),
            let symbol:ScalarIdentifier = .init(language, fragments[1])
        {
            self.init(symbol)
        }
        else
        {
            return nil
        }
    }
}
