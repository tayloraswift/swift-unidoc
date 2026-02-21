import JSONDecoding
import SymbolGraphParts
import SystemIO
import Testing

extension SymbolGraphPart {
    static func load(part path: FilePath) throws -> Self {
        let name: FilePath.Component = try #require(path.lastComponent)
        let id: SymbolGraphPart.ID = try #require(.init(name.string))

        let part: SymbolGraphPart = try .init(
            json: .init(utf8: try path.read([UInt8].self)[...]),
            id: id
        )

        #expect(part.metadata.version == .v(0, 6, 0))

        return part
    }

    func first(named path: [String]) -> SymbolGraphPart.Vertex? {
        self.vertices.first {
            switch $0.usr {
            case .vector:   false
            default:        $0.path.elementsEqual(path)
            }
        }
    }
}
