import JSON

extension GitHub
{
    @frozen public
    struct WebhookCreate:Sendable
    {
        public
        var repo:Repo

        /// Oddly enough, the API does not return the SHA-1 commit associated with the ref.
        public
        let ref:String
        public
        let refType:RefType

        @inlinable public
        init(repo:Repo, ref:String, refType:RefType)
        {
            self.repo = repo
            self.ref = ref
            self.refType = refType
        }
    }
}
extension GitHub.WebhookCreate:JSONObjectDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case repository
        case ref
        case ref_type
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            repo: try json[.repository].decode(),
            ref: try json[.ref].decode(),
            refType: try json[.ref_type].decode())
    }
}
