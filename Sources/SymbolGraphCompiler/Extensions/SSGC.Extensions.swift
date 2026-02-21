import LexicalPaths
import Signatures
import SymbolGraphParts
import Symbols

extension SSGC {
    struct Extensions {
        /// Extensions indexed by signature.
        private var groups: [ExtensionSignature: ExtensionObject]
        /// Extensions indexed by block symbol. Extensions are made up of
        /// many constituent extension blocks, so multiple block symbols can
        /// point to the same extension.
        private var named: [Symbol.Block: ExtensionObject]

        init() {
            self.groups = [:]
            self.named = [:]
        }
    }
}
extension SSGC.Extensions {
    var all: Dictionary<SSGC.ExtensionSignature, SSGC.ExtensionObject>.Values {
        self.groups.values
    }
}
extension SSGC.Extensions {
    mutating func include(
        _ vertex: SymbolGraphPart.Vertex,
        extending type: __owned Symbol.Decl,
        culture: Symbol.Module
    ) {
        guard
        case .block(let symbol) = vertex.usr,
        case .block = vertex.phylum else {
            fatalError("vertex is not an extension block!")
        }

        let signature: SSGC.ExtensionSignature = .init(
            extending: type,
            where: Set.init(vertex.extension.conditions)
        )

        let extensionObject: SSGC.ExtensionObject = self[signature]
        //  Assume there is a possibility this culture is re-exporting another culture’s
        //  extension block.
        if  let extensionBlock: SSGC.Extension.Block = .init(
                location: vertex.location,
                comment: vertex.doccomment.map { .init($0.text, at: $0.start) } ?? nil
            ) {
            { _ in }(&extensionObject.blocks[symbol, default: (extensionBlock, in: culture)])
        }

        self.named[symbol] = extensionObject
    }
}

extension SSGC.Extensions {
    subscript(named block: Symbol.Block) -> SSGC.ExtensionObject {
        get throws {
            if  let named: SSGC.ExtensionObject = self.named[block] {
                return named
            } else {
                throw SSGC.UndefinedSymbolError.extension(block)
            }
        }
    }
}
extension SSGC.Extensions {
    subscript(
        extending extended: SSGC.DeclObject,
        where conditions: Set<GenericConstraint<Symbol.Decl>>
    ) -> SSGC.ExtensionObject {
        mutating get {
            let signature: SSGC.ExtensionSignature = .init(
                extending: extended.id,
                where: conditions
            )
            return self[signature]
        }
    }

    private subscript(signature: SSGC.ExtensionSignature) -> SSGC.ExtensionObject {
        mutating get {
            {
                if  let object: SSGC.ExtensionObject = $0 {
                    return object
                } else {
                    let object: SSGC.ExtensionObject = .init(signature: signature)
                    $0 = object
                    return object
                }
            }(&self.groups[signature])
        }
    }
}
extension SSGC.Extensions {
    func load(
        culture: Symbol.Module,
        with declarations: SSGC.Declarations
    ) throws -> [SSGC.Extension] {
        /// Gather extension members attributable to the specified culture, simplifying the
        /// extension signatures by inspecting the extended declaration. This may coalesce
        /// multiple extension objects into a single extension layer.
        let coalesced: [SSGC.Extension.ID: SSGC.ExtensionLayer] = try self.all.reduce(
            into: [:]
        ) {
            let blocks: [(id: Symbol.Block, block: SSGC.Extension.Block)] = $1.blocks.reduce(
                into: []
            ) {
                if  case (let id, (let block, in: culture)) = $1 {
                    $0.append((id, block))
                }
            }

            let conformances: [Symbol.Decl] = $1.conformances.select(culture: culture)
            let features: [Symbol.Decl] = $1.features.select(culture: culture)
            let nested: [Symbol.Decl] = $1.nested.select(culture: culture)

            //  Skip empty extensions
            if  conformances.isEmpty,
                features.isEmpty,
                nested.isEmpty,
                blocks.isEmpty {
                return
            }

            let extendedType: SSGC.DeclObject = try declarations[$1.signature.extendee]
            let introduced: Set<
                GenericConstraint<Symbol.Decl>
            > = $1.signature.conditions.filter {
                /// Lint tautological `Self:#Self` constraints. These exist in extensions to
                /// ``RawRepresentable`` in the standard library, and removing them may coalesce
                /// extension objects.
                if  case .where("Self", is: .conformer, to: let conformance) = $0,
                    case extendedType.id? = conformance.nominal {
                    return false
                }
                /// Filter out constraints that are already stated in the base declaration.
                /// This by itself should not coalesce extension objects.
                if  extendedType.conditions.contains($0) {
                    return false
                } else {
                    return true
                }
            }

            let extendee: SSGC.Extendee = .init(
                namespace: extendedType.namespace,
                path: extendedType.value.path,
                id: extendedType.id
            )

            let id: SSGC.Extension.ID = .init(
                extending: extendee.id,
                where: introduced.sorted()
            )
            ;
            {
                $0.conformances.formUnion(conformances)
                $0.features.formUnion(features)
                $0.nested.formUnion(nested)
                $0.blocks += blocks

            } (&$0[id, default: .init(extendee: extendee)])
        }

        /// Sort the extension members, and the extensions themselves, for deterministic output.
        var extensions: [SSGC.Extension] = coalesced.map {
            .init(
                conditions: $0.conditions,
                extendee: $1.extendee,
                conformances: $1.conformances.sorted(),
                features: $1.features.sorted(),
                nested: $1.nested.sorted(),
                blocks: $1.blocks.sorted { $0.id.name < $1.id.name} .map { $0.block }
            )
        }
        extensions.sort { $0.id < $1.id }
        return extensions
    }
}
