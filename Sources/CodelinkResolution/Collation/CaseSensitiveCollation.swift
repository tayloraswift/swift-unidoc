import Codelinks

enum CaseSensitiveCollation:PathCollation
{
    static
    func collate(_ path:some BidirectionalCollection<String>) -> String
    {
        path.joined(separator: ".")
    }
}
