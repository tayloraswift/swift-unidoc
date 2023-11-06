import MD5

extension MD5
{
    init?<Line>(header lines:[Line]) where Line:StringProtocol, Line.SubSequence == Substring
    {
        //  We aren’t parsing this correctly, because an `if-none-match` field can contain
        //  multiples entity tags. We cannot perform a naïve split on commas, because entity
        //  tags themselves can contain commas. This implementation also won’t parse tags with
        //  the weak comparison prefix (`W/`).
        for line:Line in lines
        {
            guard
            let last:String.Index = line.indices.last,
                last != line.startIndex,
                line[line.startIndex] == "\"",
                line[last] == "\""
            else
            {
                continue
            }

            if  let tag:MD5 = .init(line[line.index(after: line.startIndex) ..< last])
            {
                self = tag
                return
            }
        }

        return nil
    }
}
