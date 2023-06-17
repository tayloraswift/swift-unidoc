import Codelinks

enum CaseInsensitiveCollation:PathCollation
{
    static
    func collate(_ path:some BidirectionalCollection<String>) -> String
    {
        path.lazy.map { $0.lowercased() } .joined(separator: "/")
    }
}
