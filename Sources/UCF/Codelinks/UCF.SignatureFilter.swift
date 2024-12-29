import Grammar

extension UCF
{
    @frozen public
    enum SignatureFilter:Equatable, Hashable, Sendable
    {
        case function([String?], [String?]? = nil)
        case returns([String?])
    }
}
extension UCF.SignatureFilter
{
    init(parsed pattern:borrowing UCF.SignaturePattern, source:borrowing Substring)
    {
        switch pattern
        {
        case .function(let inputs, let output):
            let inputs:[String?] = inputs.map { $0.provided?.formatted(source: source) }
            let output:[String?]? = output?.splatted.map
            {
                $0.provided?.formatted(source: source)
            }

            self = .function(inputs, output)

        case .returns(let output):
            let output:[String?] = output.splatted.map
            {
                $0.provided?.formatted(source: source)
            }

            self = .returns(output)
        }
    }
}
extension UCF.SignatureFilter
{
    @inlinable public
    var inputs:[String?]?
    {
        switch self
        {
        case .function(let inputs, _):  inputs
        case .returns:                  nil
        }
    }

    @inlinable public
    var output:[String?]?
    {
        switch self
        {
        case .function(_, let output):  output
        case .returns(let output):      output
        }
    }
}
extension UCF.SignatureFilter:CustomStringConvertible
{
    public
    var description:String { self.formatted(spaces: false) }
}
extension UCF.SignatureFilter
{
    func formatted(spaces:Bool) -> String
    {
        var string:String = ""

        if  let inputs:[String?] = self.inputs
        {
            string.append("(")

            var first:Bool = true
            for input:String? in inputs
            {
                if  first
                {
                    first = false
                }
                else
                {
                    string.append(spaces ? ", " : ",")
                }

                string.append(input ?? "_")
            }

            string.append(")")
        }

        guard
        let output:[String?] = self.output
        else
        {
            return string
        }

        if  spaces
        {
            string.append(string.isEmpty ? "-> " : " -> ")
        }
        else
        {
            string.append("->")
        }

        if  output.count == 1
        {
            string.append(output[0] ?? "_")
        }
        else
        {
            string.append("(")

            var first:Bool = true
            for element:String? in output
            {
                if  first
                {
                    first = false
                }
                else
                {
                    string.append(spaces ? ", " : ",")
                }

                string.append(element ?? "_")
            }

            string.append(")")
        }

        return string
    }
}
