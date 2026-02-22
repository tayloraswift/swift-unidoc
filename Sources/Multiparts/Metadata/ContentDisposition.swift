@frozen public enum ContentDisposition: Equatable, Hashable, Sendable {
    case inline
    case attachment (filename: String?)
    case formData   (filename: String?, name: String)
}
extension ContentDisposition: CustomStringConvertible {
    @inlinable public static func escape(_ string: some StringProtocol) -> String {
        var escaped: String = "\""
        for character: Character in string {
            switch character {
            case "\"":      escaped += "\\\""
            case "\\":      escaped += "\\\\"
            default:        escaped.append(character)
            }
        }
        escaped += "\""
        return escaped
    }

    @inlinable public var description: String {
        switch self {
        case .inline:
            "inline"

        case .attachment(filename: nil):
            "attachment"
        case .attachment(filename: let filename?):
            "attachment; filename=\(Self.escape(filename))"

        case .formData(filename: nil, name: let name):
            "form-data; name=\(Self.escape(name))"
        case .formData(filename: let filename?, name: let name):
            "form-data; name=\(Self.escape(name)); filename=\(Self.escape(filename))"
        }
    }
}
