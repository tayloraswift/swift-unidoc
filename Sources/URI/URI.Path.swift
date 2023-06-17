
extension URI
{
    @frozen public
    struct Path:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        var components:[Component]

        @inlinable public
        init(components:[Component])
        {
            self.components = components
        }
    }
}
extension URI.Path:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Component...)
    {
        self.init(components: arrayLiteral)
    }
}
extension URI.Path
{
    @inlinable public mutating
    func append(_ component:String)
    {
        self.append(.push(component))
    }
    @inlinable public mutating
    func append(_ component:Component)
    {
        self.components.append(component)
    }

    @inlinable public
    var normalized:[String]
    {
        var components:[String] = []
            components.reserveCapacity(self.components.count)
        for component:Component in self.components
        {
            switch component
            {
            case .empty:
                continue

            case .push(let component):
                components.append(component)

            case .pop:
                let _:String? = components.popLast()
            }
        }
        return components
    }
}
extension URI.Path:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(description[...])
    }
    public
    init?(_ description:Substring)
    {
        if  let value:Self = try? URI.AbsolutePathRule<String.Index>.parse(description.utf8)
        {
            self = value
        }
        else
        {
            return nil
        }
    }
}
extension URI.Path:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "/\(self.components.lazy.map(\.description).joined())"
    }
}
