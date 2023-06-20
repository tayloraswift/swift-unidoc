import FNV1

extension Codelink.Path
{
    enum Suffix
    {
        case filter(Codelink.Filter?)
        case hash(FNV24)
    }
}
extension Codelink.Path.Suffix
{
    var hash:FNV24?
    {
        if case .hash(let hash) = self
        {
            return hash
        }
        else
        {
            return nil
        }
    }
}
extension Codelink.Path.Suffix
{
    init(_ description:Substring)
    {
        if let hash:FNV24 = .init(description)
        {
            self = .hash(hash)
            return
        }
        else
        {
            self = .filter(.init(suffix: description))
        }
    }

    /// Reverse-scans the given string, attempting to consume a bracketed ``FNV24``
    /// hash from the end of the string.
    static
    func hash(trimming string:inout Substring) -> Self?
    {
        while   let last:Character = string.last
        {
            if      last.isWhitespace
            {
                string.removeLast()
                continue
            }
            else if last != "]"
            {
                return nil
            }
            else
            {
                break
            }
        }

        let end:String.Index = string.index(before: string.endIndex)

        if  let index:String.Index = string[..<end].lastIndex(of: "["),
            let hash:FNV24 = .init(string[string.index(after: index) ..< end])
        {
            string = string.prefix(upTo: index)
            return .hash(hash)
        }
        else
        {
            return nil
        }
    }
}
