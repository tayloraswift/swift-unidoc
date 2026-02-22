import SwiftSyntax

extension SignatureSyntax {
    @frozen @usableFromInline struct ExpandedVisitor {
        let sugarMap: SugarMap

        var actor: Bool
        private(set) var async: Bool
        private(set) var `class`: Bool
        private(set) var final: Bool

        private(set) var inputs: [String]
        private(set) var output: [String]

        @usableFromInline init(sugaring sugarMap: SugarMap) {
            self.sugarMap = sugarMap
            self.actor = false
            self.async = false
            self.class = false
            self.final = false
            self.inputs = []
            self.output = []
        }
    }
}

extension SignatureSyntax.ExpandedVisitor: SignatureVisitor {
    mutating func register(
        parameter: FunctionParameterSyntax,
        type _: SignatureParameterType
    ) -> SignatureSyntax.ExpandedParameter {
        var autographer: SignatureSyntax.Autographer = .init(sugaring: self.sugarMap)
        autographer.encode(parameter: parameter)
        inputs.append(autographer.autograph)
        return .init(syntax: parameter)
    }
}
extension SignatureSyntax.ExpandedVisitor {
    mutating func mark(with modifiers: DeclModifierListSyntax) {
        for modifier: DeclModifierSyntax in modifiers {
            switch modifier.name.tokenKind {
            case .keyword(.class):  self.class = true
            case .keyword(.final):  self.final = true
            default:                continue
            }
        }
    }

    mutating func mark(with effects: FunctionEffectSpecifiersSyntax?) {
        if  case .keyword(.async)? = effects?.asyncSpecifier?.tokenKind {
            self.async = true
        }
    }

    mutating func mark(with accessorBlock: AccessorBlockSyntax?) {
        if  case .accessors(let accessors)? = accessorBlock?.accessors {
            for accessor: AccessorDeclSyntax in accessors {
                if  let effects: AccessorEffectSpecifiersSyntax = accessor.effectSpecifiers,
                    case .keyword(.get) = accessor.accessorSpecifier.tokenKind,
                    case .keyword(.async)? = effects.asyncSpecifier?.tokenKind {
                    self.async = true
                }
            }
        }
    }
}
extension SignatureSyntax.ExpandedVisitor {
    mutating func register(returns: TypeSyntax) {
        guard
        let tuple: TupleTypeSyntax = returns.as(TupleTypeSyntax.self) else {
            self.register(output: returns)
            return
        }

        for element: TupleTypeElementSyntax in tuple.elements {
            self.register(output: element.type)
        }
    }

    private mutating func register(output: TypeSyntax) {
        var autographer: SignatureSyntax.Autographer = .init(sugaring: self.sugarMap)
        autographer.encode(type: output)
        self.output.append(autographer.autograph)
    }
}
