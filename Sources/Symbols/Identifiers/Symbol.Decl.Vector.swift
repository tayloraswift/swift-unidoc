extension Symbol.Decl
{
    /// A vector symbol resolution.
    @frozen public
    struct Vector:Equatable, Hashable
    {
        public
        let feature:Symbol.Decl
        public
        let heir:Symbol.Decl

        @inlinable public
        init(_ feature:Symbol.Decl, self heir:Symbol.Decl)
        {
            self.feature = feature
            self.heir = heir
        }
    }
}
extension Symbol.Decl.Vector:Comparable
{
    @inlinable public
    static func < (a:Self, b:Self) -> Bool
    {
        (a.feature, a.heir) < (b.feature, b.heir)
    }
}
extension Symbol.Decl.Vector:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.feature.description)::SYNTHESIZED::\(self.heir.description)"
    }
}
extension Symbol.Decl.Vector:LosslessStringConvertible
{
    public
    init?(_ string:__shared String)
    {
        guard case .vector(let vector)? = Symbol.USR.init(string)
        else
        {
            return nil
        }

        self = vector
    }
}
