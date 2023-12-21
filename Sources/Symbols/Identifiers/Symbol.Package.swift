extension Symbol
{
    @frozen public
    struct Package:Equatable, Hashable, Sendable
    {
        public
        let name:String

        @inlinable public
        init(canonical name:String)
        {
            self.name = name
        }
    }
}

extension Symbol.Package
{
    @inlinable public static
    var swift:Self { .init(canonical: "swift") }

    @inlinable public static
    var swiftPM:Self { .init(canonical: "swift-package-manager") }
}
extension Symbol.Package:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.swift, .swift):      false
        case (.swift, _):           true
        case (let lhs, let rhs):    lhs.name < rhs.name
        }
    }
}
extension Symbol.Package:CustomStringConvertible
{
    @inlinable public
    var description:String { self.name }
}
extension Symbol.Package:LosslessStringConvertible
{
    @inlinable public
    init(_ string:some StringProtocol)
    {
        switch string.lowercased()
        {
        case    "swift-standard-library",
                "swift-core-libraries":
            self = .swift

        case let name:
            self.init(canonical: name)
        }
    }
}
extension Symbol.Package:ExpressibleByStringLiteral, ExpressibleByStringInterpolation
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
