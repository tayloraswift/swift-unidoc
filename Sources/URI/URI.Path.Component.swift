extension URI.Path
{
    @frozen public
    enum Component:Equatable, Hashable, Sendable
    {
        /// A regular path component. This can be '.' or '..' if at least one
        /// of the dots was percent-encoded.
        case push(String)
        /// `..`
        case pop
    }
}
extension URI.Path.Component
{
    @inlinable public static
    var empty:Self { .push("") }
}
extension URI.Path.Component:ExpressibleByStringLiteral, ExpressibleByStringInterpolation
{
    @inlinable public
    init(stringLiteral:String)
    {
        self = .push(stringLiteral)
    }
}
extension URI.Path.Component:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(description[...])
    }
    public
    init?(_ description:Substring)
    {
        if  let value:Self = try? URI.PathComponentRule<String.Index>.parse(description.utf8)
        {
            self = value
        }
        else
        {
            return nil
        }
    }
}
extension URI.Path.Component:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .empty:                "."
        case .pop:                  ".."
        case .push(let component):  EncodingSet.encode(component)
        }
    }
}
