import IP

extension ServerProfile
{
    @frozen public
    struct Sample:Equatable, Sendable
    {
        public
        var ip:IP.Address?
        public
        var language:String?
        public
        var referer:String?
        public
        var agent:String?
        public
        var uri:String?

        @inlinable public
        init(ip:IP.Address? = nil,
            language:String? = nil,
            referer:String? = nil,
            agent:String? = nil,
            uri:String? = nil)
        {
            self.ip = ip
            self.language = language
            self.referer = referer
            self.agent = agent
            self.uri = uri
        }
    }
}
