import ArgumentParser

extension SSGC
{
    @frozen public
    enum ProjectType:CaseIterable, Equatable, Sendable
    {
        case package
        case book
    }
}
extension SSGC.ProjectType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .package:  "package"
        case .book:     "book"
        }

    }
}
extension SSGC.ProjectType:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        switch description
        {
        case "package": self = .package
        case "book":    self = .book
        default:        return nil
        }
    }
}
extension SSGC.ProjectType:ExpressibleByArgument
{
}
