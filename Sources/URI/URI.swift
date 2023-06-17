import Grammar

@frozen public
struct URI:Sendable
{
    public
    typealias Parameter = (key:String, value:String)

    public
    var path:Path
    public
    var query:[Parameter]?

    @inlinable public
    init(path:Path, query:[Parameter]? = nil)
    {
        self.path = path
        self.query = query
    }
}
extension URI
{
    @inlinable public mutating
    func insert(parameter:Parameter)
    {
        switch self.query
        {
        case nil:
            self.query = [parameter]
        case var parameters?:
            self.query = nil
            parameters.append(parameter)
            self.query = parameters
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
    init?(_ description:String)
    {
        self.init(description[...])
    }
    public
    init?(_ description:Substring)
    {
        if  let value:Self = try? URI.Rule<String.Index>.parse(description.utf8)
        {
            self = value
        }
        else
        {
            return nil
        }
    }
}
extension URI:CustomStringConvertible
{
    public
    var description:String
    {
        var string:String = "\(self.path)"

        if  let parameters:[Parameter] = self.query
        {
            // don’t bother percent-encoding the query parameters
            string.append("?")
            string += parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        }

        return string
    }
}
extension URI
{
    @inlinable public static
    func ~= (lhs:Self, rhs:Self) -> Bool
    {
        guard lhs.path == rhs.path
        else
        {
            return false
        }
        switch (lhs.query, rhs.query)
        {
        case (_?, nil), (nil, _?):
            return false
        case (nil, nil):
            return true
        case (let lhs?, let rhs?):
            guard lhs.count == rhs.count
            else
            {
                return false
            }
            var unmatched:[String: String] = .init(minimumCapacity: lhs.count)
            for (key, value):(String, String) in lhs
            {
                guard case nil = unmatched.updateValue(value, forKey: key)
                else
                {
                    return false
                }
            }
            for (key, value):(String, String) in rhs
            {
                guard case value? = unmatched.removeValue(forKey: key)
                else
                {
                    return false
                }
            }
            return true
        }
    }
}
