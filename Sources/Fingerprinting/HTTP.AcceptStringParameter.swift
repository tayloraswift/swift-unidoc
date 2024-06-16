import HTTP

extension HTTP
{
    @frozen @usableFromInline
    struct AcceptStringParameter
    {
        @usableFromInline
        let key:Substring
        @usableFromInline
        var q:Double?
        @usableFromInline
        var v:Substring?

        @inlinable
        init(key:Substring, q:Double? = nil, v:Substring? = nil)
        {
            self.key = key
            self.q = q
            self.v = v
        }
    }
}
extension HTTP.AcceptStringParameter
{
    @inlinable
    init(_ string:Substring)
    {
        var semicolon:String.Index?

        if  let i:String.Index = string.firstIndex(of: ";")
        {
            self.init(key: string[..<i])
            semicolon = i
        }
        else
        {
            self.init(key: string)
        }

        while let current:String.Index = semicolon
        {
            let start:String.Index = string.index(after: current)

            semicolon = string[start...].firstIndex(of: ";")

            let pair:Substring

            if  let semicolon:String.Index
            {
                pair = string[start ..< semicolon]
            }
            else
            {
                pair = string[start...]
            }

            guard
            let equals:String.Index = pair.firstIndex(of: "=")
            else
            {
                continue
            }

            let value:Substring = pair[pair.index(after: equals)...]

            switch pair[..<equals]
            {
            case "q":
                guard
                let value:Double = .init(value)
                else
                {
                    continue
                }

                self.q = value

            case "v":
                self.v = value

            default:
                continue
            }
        }
    }
}
