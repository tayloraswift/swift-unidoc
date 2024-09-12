import URI

extension URI
{
    protocol QueryDecodable
    {
        init?(parameters:borrowing [String: String])
    }
}
extension URI.QueryDecodable
{
    init?(from query:borrowing URI.Query)
    {
        self.init(parameters: query.parameters.reduce(into: [:]) { $0[$1.key] = $1.value })
    }
}
