extension URI
{
    @frozen public
    struct Query:Sendable
    {
        public
        typealias Parameter = (key:String, value:String)

        public
        var parameters:[Parameter]

        @inlinable internal
        init(_ parameters:[Parameter])
        {
            self.parameters = parameters
        }
    }
}
extension URI.Query:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(String, String)...)
    {
        self.init(dictionaryLiteral)
    }
}
extension URI.Query:CustomStringConvertible
{
    public
    var description:String
    {
        var string:String = "?"
        var first:Bool = true
        for (key, value):(String, String) in self.parameters
        {
            if  first
            {
                first = false
            }
            else
            {
                string.append("&")
            }

            string += "\(key)=\(EncodingSet.encode(value))"
        }
        return string
    }
}
extension URI.Query:LosslessStringConvertible
{
    public
    init?(_ description:String)
    {
        self.init(description[...])
    }

    public
    init?(_ description:Substring)
    {
        do
        {
            self = try URI.QueryRule<String.Index>.parse(description.utf8)
        }
        catch
        {
            return nil
        }
    }
}
extension URI.Query
{
    /// Parses query parameters from UTF-8 text. This parser does not expect a leading
    /// question mark (`?`).
    public static
    func parse(parameters:[UInt8]) throws -> Self
    {
        .init(try URI.QueryRule<Int>.Parameters.parse(parameters))
    }
}
extension URI.Query:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        guard lhs.parameters.count == rhs.parameters.count
        else
        {
            return false
        }
        var unmatched:[String: String] = .init(minimumCapacity: lhs.parameters.count)
        for (key, value):(String, String) in lhs.parameters
        {
            guard case nil = unmatched.updateValue(value, forKey: key)
            else
            {
                return false
            }
        }
        for (key, value):(String, String) in rhs.parameters
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
