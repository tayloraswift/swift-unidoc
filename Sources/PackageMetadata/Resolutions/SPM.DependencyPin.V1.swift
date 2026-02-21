import JSON
import Symbols

extension SPM.DependencyPin {
    struct V1 {
        let value: SPM.DependencyPin

        private init(value: SPM.DependencyPin) {
            self.value = value
        }
    }
}

extension SPM.DependencyPin.V1: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        //  this field is completely useless!
        //  case id = "package"

        case location = "repositoryURL"
        case state
    }
    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        let location: SPM.DependencyLocation = .init(
            location: try json[.location].decode()
        )

        self.init(
            value: .init(
                identity: Symbol.Package.init(location.name),
                location: location,
                state: try json[.state].decode()
            )
        )
    }
}
