@frozen public 
struct PackageIdentifier:Equatable, Hashable, Sendable
{
    public
    let canonical:String

    @inlinable public
    init(canonical:String)
    {
        self.canonical = canonical
    }
}
extension PackageIdentifier
{
    @inlinable public static
    var corelibs:Self
    {
        .init(canonical: "corelibs")
    }
    @inlinable public static
    var swift:Self
    {
        .init(canonical: "swift")
    }
}
extension PackageIdentifier:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.swift, .swift):
            return false
        case (.swift, _):
            return true
        case (let lhs, let rhs):
            return lhs.canonical < rhs.canonical
        }
    }
}
extension PackageIdentifier:CustomStringConvertible
{
    @inlinable public 
    var description:String 
    {
        self.canonical
    }
}
extension PackageIdentifier:LosslessStringConvertible
{
    @inlinable public
    init(_ string:some StringProtocol)
    {
        switch string.lowercased() 
        {
        case    "swift-standard-library",
                "standard-library",
                "swift-stdlib",
                "stdlib":
            self = .swift
        
        case    "swift-core-libraries", 
                "corelibs":
            self = .corelibs
        
        case let name:
            self.init(canonical: name)
        }
    }
}
extension PackageIdentifier:ExpressibleByStringLiteral
{
    @inlinable public 
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
