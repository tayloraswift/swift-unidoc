import Symbols

public
struct Codelink
{

}


extension Codelink
{
    enum Word
    {
        case path(Substring)
        case type(Substring)
    }
}
extension Codelink
{
    init?(parsing string:String)
    {
        let words:[Substring] = string.split(separator: " ")

        guard let last:Substring = words.last
        else
        {
            return nil
        }

        var prefix:ArraySlice<Substring> = words.dropLast()

        let phylum:SymbolPhylum.Filter?
        if  let keyword:Substring = prefix.first,
            let keyword:SymbolPhylum.Keyword = .init(rawValue: .init(keyword))
        {
            var remaining:ArraySlice<Substring> = prefix.dropFirst()
            if      let next:Substring = remaining.popFirst()
            {
                phylum = .init(keyword, next)
            }
            else
            {
                phylum = .init(keyword)
            }
            if  case _? = phylum
            {
                prefix = remaining
            }
        }
        else
        {
            phylum = nil
        }

        if prefix.count < 2
        {
            self.init(phylum: phylum, scope: prefix.first, last: last)
        }
        else
        {
            return nil
        }

    }

    private
    init?(phylum:SymbolPhylum.Filter?, scope:Substring?, last:Substring)
    {

    }
}
