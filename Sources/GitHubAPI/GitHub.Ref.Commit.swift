import JSON
import SHA1
import SHA1_JSON

extension GitHub.Ref
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
extension GitHub.Ref.Commit:JSONObjectDecodable
{
    enum CodingKey:String, Sendable
    {
        case sha
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(sha: try json[.sha].decode())
    }
}
