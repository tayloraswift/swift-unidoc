import Symbols

extension SymbolGraphPart {
    @frozen public struct ID: Equatable, Hashable, Sendable {
        public let culture: Symbol.Module
        public let colony: Symbol.Module?

        @inlinable public init(culture: Symbol.Module, colony: Symbol.Module? = nil) {
            self.culture = culture
            self.colony = colony
        }
    }
}
extension SymbolGraphPart.ID {
    @inlinable public init(filename: String) throws {
        if  let id: Self = .init(filename) {
            self = id
        } else {
            throw SymbolGraphPart.IdentificationError.filename(filename)
        }
    }

    @inlinable public var namespace: Symbol.Module {
        self.colony ?? self.culture
    }
    public var basename: String {
        self.colony.map { "\(self.culture)@\($0)" } ?? "\(self.culture)"
    }
}
extension SymbolGraphPart.ID: CustomStringConvertible {
    public var description: String {
        "\(self.basename).symbols.json"
    }
}
extension SymbolGraphPart.ID: LosslessStringConvertible {
    public init?(_ description: String) {
        let components: [Substring] = description.split(separator: ".")
        if  components.count == 3,
            components[1 ... 2] == ["symbols", "json"] {
            let names: [Substring] = components[0].split(
                separator: "@",
                maxSplits: 1,
                omittingEmptySubsequences: false
            )

            switch names.count {
            case 1:
                self.init(culture: .init(String.init(names[0])))

            case 2:
                self.init(
                    culture: .init(String.init(names[0])),
                    colony: .init(String.init(names[1]))
                )

            case _:
                return nil
            }
        } else {
            return nil
        }
    }
}
