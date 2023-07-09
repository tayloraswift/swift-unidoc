public
protocol VectorVersion:LosslessStringConvertible, RawRepresentable<Int64>, Comparable
{
    associatedtype Components:VectorVersionComponents

    init(components:Components)
    var components:Components { get }
}
extension VectorVersion where Self:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.components < rhs.components
    }
}
extension VectorVersion where Self:RawRepresentable<Int64>
{
    @inlinable public
    var rawValue:Int64 { self.components.rawValue }
    @inlinable public
    init(rawValue:Int64)
    {
        self.init(components: .init(rawValue: rawValue))
    }
}
extension VectorVersion where Self:LosslessStringConvertible
{
    @inlinable public
    var description:String { self.components.description }

    /// Attempts to parse a semantic version from a dot-separated triple, such as `1.2.3`.
    /// This initializer does not accept `v`-prefixed strings; use ``init(tag:)`` to accept
    /// an optional `v` prefix.
    @inlinable public
    init?(_ string:String)
    {
        self.init(string[...])
    }
}
extension VectorVersion
{
    @inlinable public
    init?(_ string:Substring)
    {
        if  let components:Components = .init(string)
        {
            self.init(components: components)
        }
        else
        {
            return nil
        }
    }
}
