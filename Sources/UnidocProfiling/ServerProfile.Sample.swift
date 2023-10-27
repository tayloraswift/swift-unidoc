import IP

extension ServerProfile
{
    @frozen public
    struct Sample:Equatable, Sendable
    {
        public
        var ip:IP.V6
        public
        var language:String?
        public
        var referer:String?
        public
        var agent:String?
        public
        var http2:Bool
        public
        var uri:String

        @inlinable public
        init(ip:IP.V6,
            language:String? = nil,
            referer:String? = nil,
            agent:String? = nil,
            http2:Bool = true,
            uri:String)
        {
            self.ip = ip
            self.language = language
            self.referer = referer
            self.agent = agent
            self.http2 = http2
            self.uri = uri
        }
    }
}
