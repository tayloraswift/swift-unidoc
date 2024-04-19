import Grammar

@frozen public
struct URI:Sendable
{
    public
    var path:Path
    @usableFromInline
    var parameters:[Query.Parameter]?

    @inlinable public
    init(path:Path, query:Query? = nil)
    {
        self.path = path
        self.parameters = query?.parameters
    }
}
extension URI
{
    /// Non-settable, so you do not accidentally drop parameters with optional mutations.
    @inlinable public
    var query:Query? { self.parameters.map(Query.init(_:)) }

    /// Appends a new query parameter to this URI’s parameter list, creating it
    /// if it does not exist. The getter always returns nil.
    @inlinable public
    subscript(key:String) -> String?
    {
        get
        {
            nil
        }
        set(value)
        {
            guard let value:String
            else
            {
                return
            }
            switch self.parameters
            {
            case nil:
                self.parameters = [(key, value)]

            case var parameters?:
                self.parameters = nil
                parameters.append((key, value))
                self.parameters = parameters
            }
        }
    }
}
extension URI:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Path.Component...)
    {
        self.init(path: .init(components: arrayLiteral))
    }
}
extension URI:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:borrowing String)
    {
        self.init(description[...])
    }
    public
    init?(_ description:borrowing Substring)
    {
        do
        {
            self = try URI.Rule<String.Index>.parse(description.utf8)
        }
        catch
        {
            return nil
        }
    }
}
extension URI:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.query.map { "\(self.path)\($0)" } ?? "\(self.path)"
    }
}
extension URI:Equatable
{
    @inlinable public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        guard lhs.path == rhs.path
        else
        {
            return false
        }
        switch (lhs.query, rhs.query)
        {
        case (_?, nil), (nil, _?):  return false
        case (let lhs?, let rhs?):  return lhs == rhs
        case (nil, nil):            return true
        }
    }
}
