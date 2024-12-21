extension UCF
{
    @frozen public
    enum PatternFilter:Equatable, Hashable, Sendable
    {
        case fullSignature([Identifier], Output)
        case inputs([Identifier])
        case output(Output)
    }
}
extension UCF.PatternFilter
{
    @inlinable public
    var inputs:[Identifier]?
    {
        switch self
        {
        case .fullSignature(let inputs, _): inputs
        case .inputs(let inputs):           inputs
        case .output:                       nil
        }
    }

    @inlinable public
    var output:Output?
    {
        switch self
        {
        case .fullSignature(_, let output): output
        case .inputs:                       nil
        case .output(let output):           output
        }
    }
}
extension UCF.PatternFilter:CustomStringConvertible
{
    public
    var description:String
    {
        var string:String = ""

        if  let inputs:[UCF.PatternFilter.Identifier] = self.inputs
        {
            string.append("(")

            var first:Bool = true
            for input:UCF.PatternFilter.Identifier in inputs
            {
                if  first
                {
                    first = false
                }
                else
                {
                    string.append(",")
                }

                string.append("\(input)")
            }

            string.append(")")
        }

        guard
        let output:UCF.PatternFilter.Output = self.output
        else
        {
            return string
        }

        if !string.isEmpty
        {
            string.append("-")
        }

        string.append(">")

        switch output
        {
        case .single(let output):
            string.append("\(output)")

        case .tuple(let outputs):
            string.append("(")

            var first:Bool = true
            for output:UCF.PatternFilter.Identifier in outputs
            {
                if  first
                {
                    first = false
                }
                else
                {
                    string.append(",")
                }

                string.append("\(output)")
            }

            string.append(")")
        }

        return string
    }
}
extension UCF.PatternFilter
{
    static func parse(_ string:Substring) -> Self?
    {
        guard
        let first:Character = string.first
        else
        {
            return nil
        }

        switch first
        {
        case "(":
            let i:String.Index = string.index(after: string.startIndex)

            guard
            let j:String.Index = string[i...].firstIndex(of: ")")
            else
            {
                return nil
            }

            var inputs:[UCF.PatternFilter.Identifier] = []
            for input:Substring in string[i ..< j].split(separator: ",",
                omittingEmptySubsequences: false)
            {
                guard
                let input:UCF.PatternFilter.Identifier = .init(input)
                else
                {
                    return nil
                }

                inputs.append(input)
            }

            let k:String.Index = string.index(after: j)

            if  let l:String.Index = string.index(k, offsetBy: 2, limitedBy: string.endIndex),
                string[k ..< l] == "->"
            {
                guard
                let output:UCF.PatternFilter.Output = .parse(string[l...])
                else
                {
                    return nil
                }

                return .fullSignature(inputs, output)
            }

            return .inputs(inputs)

        case ">":
            //  This pattern contains an output only.
            let i:String.Index = string.index(after: string.startIndex)
            guard
            let output:UCF.PatternFilter.Output = .parse(string[i...])
            else
            {
                return nil
            }

            return .output(output)

        default:
            return nil
        }
    }
}
