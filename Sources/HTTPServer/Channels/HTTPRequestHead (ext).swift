import MD5
import NIOHTTP1

extension HTTPRequestHead
{
    var etag:MD5?
    {
        guard   let etag:Substring = self.headers[canonicalForm: "if-none-match"].first,
                    etag.startIndex != etag.endIndex
        else
        {
            return nil
        }

        let last:String.Index = etag.index(before: etag.endIndex)

        if  etag.startIndex < last, etag[etag.startIndex] == "\"", etag[last] == "\""
        {
            return .init(etag[etag.index(after: etag.startIndex) ..< last])
        }
        else
        {
            return nil
        }
    }
}
