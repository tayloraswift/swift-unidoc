extension Symbol
{
    @frozen public
    struct Package:Equatable, Hashable, Sendable
    {
        /// The string identifier wrapped by this symbol. It may or may not contain dots, and
        /// is always lowercased.
        public
        let identifier:String

        @inlinable
        init(identifier:String)
        {
            self.identifier = identifier
        }
    }
}

extension Symbol.Package
{
    @inlinable public static
    var swift:Self { .init(identifier: "swift") }

    @inlinable public static
    var swiftPM:Self { .init(identifier: "swift-package-manager") }
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
        case (let lhs, let rhs):    lhs.identifier < rhs.identifier
        }
    }
}
extension Symbol.Package:CustomStringConvertible
{
    @inlinable public
    var description:String { self.identifier }
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

        case let identifier:
            self.init(identifier: identifier)
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
extension Symbol.Package
{
    @inlinable public static
    func | (a:Symbol.PackageScope, b:Self) -> Self { .init(identifier: "\(a).\(b)") }
}
