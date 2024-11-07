extension URI
{
    @frozen public
    struct Query:Sendable
    {
        public
        typealias Parameter = (key:String, value:String)

        public
        var parameters:[Parameter]

        @inlinable
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
extension URI.Query
{
    static
    func += (string:inout String, self:Self)
    {
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
    }

    /// Formats the query parameters as a string without a leading question mark (`?`). This
    /// property uses `&` to separate parameters.
    ///
    /// This property percent-encodes the query values as needed. It does not percent-encode
    /// the query keys.
    public
    var encoded:String
    {
        var string:String = ""
            string += self
        return string
    }
}
extension URI.Query:CustomStringConvertible
{
    /// Formats the query parameters as a string with a leading question mark (`?`). This
    /// property uses `&` to separate parameters.
    ///
    /// This property percent-encodes the query values as needed. It does not percent-encode
    /// the query keys.
    public
    var description:String
    {
        var string:String = "?"
            string += self
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
