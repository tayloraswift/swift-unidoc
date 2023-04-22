import Availability
import JSONDecoding
import SemanticVersions

extension Availability:JSONDecodable
{
    public
    enum CodingKeys:String
    {
        case domain

        case deprecated
        case introduced
        case obsoleted

        case isUnconditionallyDeprecated
        case isUnconditionallyUnavailable

        case message
        case renamed
    }

    public
    init(json:JSON) throws
    {
        self.init()

        for json:JSON.ObjectDecoder<CodingKeys> in
            try [JSON.ObjectDecoder<CodingKeys>].init(json: json)
        {
            let message:String? = try json[.message]?.decode()
            let renamed:String? = try json[.renamed]?.decode()

            switch try json[.domain].decode(to: Availability.DomainIdentifier.self)
            {
            case .all:
                self[nil] = .init(
                    deprecated: try json[.isUnconditionallyDeprecated]?.decode(
                        as: Bool.self)
                    {
                        $0 ? .unconditionally : nil
                    },
                    renamed: renamed,
                    message: message)
            
            case .agnostic(let domain):
                //  The compiler will allow you to omit a version number from
                //  agnostic availabilities, but this makes it meaningless, so
                //  we ignore it unless there is a version number.
                self[domain] = .init(
                    deprecated: try json[.deprecated]?.decode(),
                    introduced: try json[.introduced]?.decode(),
                    obsoleted: try json[.obsoleted]?.decode(),
                    renamed: renamed,
                    message: message)
            
            case .platform(let domain):
                self[domain] = .init(
                    unavailable: try json[.isUnconditionallyUnavailable]?.decode(
                        as: Bool.self)
                    {
                        $0 ? .unconditionally : nil
                    },
                    deprecated: try json[.isUnconditionallyDeprecated]?.decode(
                        as: Bool.self)
                    {
                        $0 ? .unconditionally : nil
                    } ?? json[.deprecated]?.decode(as: SemanticVersionMask.self,
                        with: Availability.DeprecatedMask.since(_:)),
                    introduced: try json[.introduced]?.decode(),
                    obsoleted: try json[.obsoleted]?.decode(),
                    renamed: renamed,
                    message: message)
            }
        }
    }
}
