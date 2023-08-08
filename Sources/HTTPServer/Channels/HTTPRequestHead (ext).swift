import NIOHTTP1
import SHA2

extension HTTPRequestHead
{
    var etag:SHA256?
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
            return .init(parsing: etag[etag.index(after: etag.startIndex) ..< last].utf8)
        }
        else
        {
            return nil
        }
    }
}
