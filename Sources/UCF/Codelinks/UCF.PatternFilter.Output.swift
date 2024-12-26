extension UCF.PatternFilter
{
    @frozen public
    enum Output:Equatable, Hashable, Sendable
    {
        case single(String?)
        case tuple([String?])
    }
}
extension UCF.PatternFilter.Output
{
    static func parse(_ string:Substring) -> Self?
    {
        guard
        let i:String.Index = string.firstIndex(of: "("),
        let k:String.Index = string.lastIndex(of: ")")
        else
        {
            guard
            let identifier:UCF.PatternFilter.Identifier = .init(string)
            else
            {
                return nil
            }

            return .single(identifier.value)
        }

        guard i < k
        else
        {
            return nil
        }

        let j:String.Index = string.index(after: i)

        //  If we do not check for this, ``BidirectionalCollection.split`` will emit a single
        //  empty substring due to `omitEmptySubsequences`.
        if  j == k
        {
            return .tuple([])
        }

        var outputs:[String?] = []
        for output:Substring in string[j ..< k].split(separator: ",",
            omittingEmptySubsequences: false)
        {
            guard
            let output:UCF.PatternFilter.Identifier = .init(output)
            else
            {
                return nil
            }

            outputs.append(output.value)
        }

        return outputs.count == 1 ? .single(outputs[0]) : .tuple(outputs)
    }
}
