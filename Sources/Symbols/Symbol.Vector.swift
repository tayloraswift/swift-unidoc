import Symbolics

extension Symbol
{
    /// A vector symbol resolution.
    @frozen public
    struct Vector:Equatable, Hashable
    {
        public
        let feature:Scalar
        public
        let heir:Scalar

        @inlinable public
        init(_ feature:Scalar, self heir:Scalar)
        {
            self.feature = feature
            self.heir = heir
        }
    }
}
extension Symbol.Vector:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.feature.description)::SYNTHESIZED::\(self.heir.description)"
    }
}
extension Symbol.Vector:LosslessStringConvertible
{
    public
    init?(_ description:__shared String)
    {
        self.init(fragments: description.split(separator: ":", maxSplits: 4,
            omittingEmptySubsequences: true))
    }
    init?(fragments:__shared [Substring])
    {
        if  fragments.count == 5,
            let language:Unicode.Scalar = .init(fragments[0]),
            let member:ScalarIdentifier = .init(language, fragments[1]),
            fragments[2] == "SYNTHESIZED",
            let language:Unicode.Scalar = .init(fragments[3]),
            let heir:ScalarIdentifier = .init(language, fragments[4])
        {
            self.init(.init(member), self: .init(heir))
        }
        else
        {
            return nil
        }
    }
}
