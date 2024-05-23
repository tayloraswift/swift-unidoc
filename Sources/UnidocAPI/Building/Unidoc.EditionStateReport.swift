import JSON
import Symbols

extension Unidoc
{
    @frozen public
    struct EditionStateReport:Sendable
    {
        public
        let id:Edition
        public
        let volume:Symbol.Edition?
        public
        let builds:[BuildStatus]

        init(id:Edition, volume:Symbol.Edition?, builds:[BuildStatus] = [])
        {
            self.id = id
            self.volume = volume
            self.builds = builds
        }
    }
}
extension Unidoc.EditionStateReport
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id
        case volume
        case builds
    }
}
extension Unidoc.EditionStateReport:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.id] = self.id.version
        json[.volume] = self.volume
        //  Why isn’t there a JSONArrayEncodable?
        json[.builds]
        {
            for build in self.builds
            {
                $0[+] = build
            }
        }
    }
}
