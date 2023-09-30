import HTTP
import MD5

extension Cache
{
    struct Request:Equatable, Hashable, Sendable
    {
        let key:Key
        let tag:MD5?

        init(_ key:Key, tag:MD5?)
        {
            self.key = key
            self.tag = tag
        }
    }
}
