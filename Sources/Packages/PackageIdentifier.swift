@frozen public 
struct PackageIdentifier:RawRepresentable, Hashable, Equatable, Sendable
{
    public
    let rawValue:String

    @inlinable public
    init(rawValue:String)
    {
        self.rawValue = rawValue
    }
}
extension PackageIdentifier
{
    @inlinable public static
    var corelibs:Self
    {
        .init(rawValue: "corelibs")
    }
    @inlinable public static
    var swift:Self
    {
        .init(rawValue: "swift")
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
            self.init(rawValue: name)
        }
    }
    @inlinable public 
    var description:String 
    {
        self.rawValue
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
            return lhs.rawValue < rhs.rawValue
        }
    }
}
