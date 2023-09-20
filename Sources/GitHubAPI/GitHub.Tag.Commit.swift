import JSON
import SHA1

extension GitHub.Tag
{
    struct Commit
    {
        let sha:SHA1

        init(sha:SHA1)
        {
            self.sha = sha
        }
    }
}
extension GitHub.Tag.Commit:JSONObjectDecodable
{
    enum CodingKey:String
    {
        case sha
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(sha: try json[.sha].decode())
    }
}
