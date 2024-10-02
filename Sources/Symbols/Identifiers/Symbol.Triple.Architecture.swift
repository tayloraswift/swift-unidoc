extension Symbol.Triple
{
    @frozen public
    struct Architecture:Equatable, Hashable, Sendable
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
extension Symbol.Triple.Architecture:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(name: stringLiteral) }
}
extension Symbol.Triple.Architecture:CustomStringConvertible
{
    @inlinable public
    var description:String { self.name }
}
extension Symbol.Triple.Architecture
{
    @available(*, unavailable, message: "Aarch64 can be encoded as either 'arm64' or 'aarch64")
    public
    static var aarch64:Self { "aarch64" }

    @available(*, unavailable, message: "Aarch64 can be encoded as either 'arm64' or 'aarch64")
    public
    static var arm64:Self { "arm64" }

    @inlinable public
    static var x86_64:Self { "x86_64" }
}
