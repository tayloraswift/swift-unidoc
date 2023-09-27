import MD5
import NIOHTTP1

extension HTTPHeaders
{
    var ifNoneMatch:[Substring]
    {
        //  We aren’t parsing this correctly, because an `if-none-match` field can contain
        //  multiples entity tags. We cannot perform a naïve split on commas, because entity
        //  tags themselves can contain commas. This implementation also won’t parse tags with
        //  the weak comparison prefix (`W/`).
        self[canonicalForm: "if-none-match"].compactMap
        {
            if  $0.startIndex == $0.endIndex
            {
                return nil
            }

            let last:String.Index = $0.index(before: $0.endIndex)

            if  $0.startIndex < last, $0[$0.startIndex] == "\"", $0[last] == "\""
            {
                return $0[$0.index(after: $0.startIndex) ..< last]
            }
            else
            {
                return nil
            }
        }
    }
}
