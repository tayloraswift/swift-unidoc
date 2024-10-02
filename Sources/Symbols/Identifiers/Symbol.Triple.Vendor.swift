extension Symbol.Triple 
{
    @frozen public
    struct Vendor:Equatable, Hashable, Sendable
    {
        public
        let name:String

        @inlinable 
        init(name:String)
        {
            self.name = name
        }
    }
}
extension Symbol.Triple.Vendor:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(name: stringLiteral) }
}
