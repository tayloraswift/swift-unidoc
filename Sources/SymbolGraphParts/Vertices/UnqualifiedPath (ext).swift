import JSONDecoding
import LexicalPaths
import Signatures

extension UnqualifiedPath: JSONDecodable {
    public init(json: JSON.Node) throws {
        let json: JSON.Array = try .init(json: json)
        try json.shape.expect { $0 > 0 }

        let last: Int = json.index(before: json.endIndex)
        self.init(
            try json[..<last].map { try $0.decode() },
            try json[last].decode()
        )
    }
}
extension UnqualifiedPath {
    func prefixFormatted(
        inserting generics: [GenericParameter],
        spaces: Bool = false
    ) -> String {
        /// We already know that the generics are sorted by (depth, index).
        let parameters: [UInt: [String]] = generics.reduce(into: [:]) {
            $0[$1.depth, default: []].append($1.name)
        }

        var string: String = ""
        for (i, component): (UInt, String) in zip(0..., self.prefix) {
            if  i > 0 {
                string.append(".")
            }

            string.append(component)

            guard let parameters: [String] = parameters[i] else {
                continue
            }

            string.append("<")
            string.append(parameters.joined(separator: spaces ? ", " : ","))
            string.append(">")
        }

        return string
    }
}
