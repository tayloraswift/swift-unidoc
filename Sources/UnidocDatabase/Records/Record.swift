@frozen public
enum Record
{
}
extension Record
{
    @frozen public
    enum CodingKeys:String
    {
        case id = "_id"

        case package = "P"
        case version = "V"
        case recency = "S"

        case min = "L"
        case max = "U"

        case overview = "O"
        case details = "D"
    }

    static
    subscript(key:CodingKeys) -> String
    {
        key.rawValue
    }
}
