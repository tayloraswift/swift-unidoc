import SwiftSyntax

extension SignatureSyntax
{
    struct Builder<Visitor>:~Copyable where Visitor:SignatureVisitor
    {
        private(set)
        var encoder:Encoder
        private(set)
        var visitor:Visitor

        init(visitor:Visitor)
        {
            self.encoder = .init()
            self.visitor = visitor
        }
    }
}
extension SignatureSyntax.Builder
{
    private mutating func register(parameters clause: FunctionParameterClauseSyntax, type: SignatureParameterType, trimAfter: Bool = false) {
        self.encoder += clause.leftParen
        for parameter: FunctionParameterSyntax in clause.parameters {
            self.encoder.wbr(indent: true)
            self.encoder += self.visitor.register(parameter: parameter, type: type)
        }

        self.encoder.wbr(indent: false)

        if  trimAfter {
            self.encoder += clause.rightParen.trimmedPreservingLocation
        } else {
            self.encoder += clause.rightParen
        }
    }
}

extension SignatureSyntax.Builder<SignatureSyntax.ExpandedVisitor>
{
    mutating
    func encode(decl:DeclSyntax)
    {
        //  It’s easier to detect the return type this way, since we don’t inject any
        //  indentation markers into its syntax.
        if  let decl:InitializerDeclSyntax = decl.as(InitializerDeclSyntax.self)
        {
            self.visitor.mark(with: decl.modifiers)
            self.visitor.mark(with: decl.signature.effectSpecifiers)
        }
        else if
            let decl:FunctionDeclSyntax = decl.as(FunctionDeclSyntax.self)
        {
            self.visitor.mark(with: decl.modifiers)
            self.visitor.mark(with: decl.signature.effectSpecifiers)
            if  let returns:ReturnClauseSyntax = decl.signature.returnClause
            {
                self.visitor.register(returns: returns.type)
            }
        }
        else if
            let decl:SubscriptDeclSyntax = decl.as(SubscriptDeclSyntax.self)
        {
            self.visitor.mark(with: decl.modifiers)
            self.visitor.mark(with: decl.accessorBlock)

            self.visitor.register(returns: decl.returnClause.type)
        }
        else if
            let decl:VariableDeclSyntax = decl.as(VariableDeclSyntax.self),
            let binding:PatternBindingSyntax = decl.bindings.first
        {
            self.visitor.mark(with: decl.modifiers)
            self.visitor.mark(with: binding.accessorBlock)
            if  let type:TypeSyntax = binding.typeAnnotation?.type
            {
                self.visitor.register(returns: type)
            }
        }
        else if
            let decl:ActorDeclSyntax = decl.as(ActorDeclSyntax.self)
        {
            self.visitor.mark(with: decl.modifiers)
            self.visitor.actor = true
        }
        else if
            let decl:ClassDeclSyntax = decl.as(ClassDeclSyntax.self)
        {
            self.visitor.mark(with: decl.modifiers)
        }

        for region:Syntax in decl.children(viewMode: .sourceAccurate)
        {
            if  let region:TokenSyntax = region.as(TokenSyntax.self)
            {
                //  Do we still need this?
                self.encoder[at: .toplevel] += region
            }
            else if
                let region:AttributeListSyntax = region.as(AttributeListSyntax.self)
            {
                self.encoder[at: .toplevel] += region
            }
            else if
                let region:DeclModifierListSyntax = region.as(DeclModifierListSyntax.self)
            {
                //  Do we still need this?
                self.encoder[at: .toplevel] += region
            }
            else if
                let clause:GenericParameterClauseSyntax =
                    region.as(GenericParameterClauseSyntax.self)
            {
                self.encode(clause)
            }
            else if
                let region:FunctionSignatureSyntax = region.as(FunctionSignatureSyntax.self)
            {
                for region:Syntax in region.children(viewMode: .sourceAccurate)
                {
                    if  let clause:FunctionParameterClauseSyntax =
                            region.as(FunctionParameterClauseSyntax.self)
                    {
                        self.register(parameters: clause, type: .func)
                    }
                    else
                    {
                        self.encoder += region
                    }
                }
            }
            //  Subscript inputs and outputs are “shallow”
            else if
                let clause:FunctionParameterClauseSyntax =
                    region.as(FunctionParameterClauseSyntax.self)
            {
                self.register(parameters: clause, type: .subscript)
            }
            else
            {
                self.encoder += region
            }
        }
    }

    private mutating
    func encode(_ clause:GenericParameterClauseSyntax)
    {
        for region:Syntax in clause.children(viewMode: .sourceAccurate)
        {
            if  let region:GenericParameterListSyntax =
                    region.as(GenericParameterListSyntax.self)
            {
                for region:GenericParameterSyntax in region
                {
                    for region:Syntax in region.children(viewMode: .sourceAccurate)
                    {
                        if  let region:TokenSyntax = region.as(TokenSyntax.self),
                            case .identifier = region.tokenKind
                        {
                            self.encoder[in: .typealias] += region
                        }
                        else
                        {
                            self.encoder += region
                        }
                    }
                }
            }
            else
            {
                self.encoder += region
            }
        }
    }
}

extension SignatureSyntax.Builder<SignatureSyntax.AbridgedVisitor>
{
    mutating
    func encode(decl:DeclSyntax)
    {
        if  let decl:ActorDeclSyntax = decl.as(ActorDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.actorKeyword
            self.encoder[at: .toplevel] += decl.name.trimmedPreservingLocation
            self.encode(decl.genericParameterClause)
        }
        else if
            let decl:AssociatedTypeDeclSyntax = decl.as(AssociatedTypeDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.associatedtypeKeyword
            self.encoder[at: .toplevel] += decl.name.trimmedPreservingLocation
        }
        else if
            let decl:ClassDeclSyntax = decl.as(ClassDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.classKeyword
            self.encoder[at: .toplevel] += decl.name.trimmedPreservingLocation
            self.encode(decl.genericParameterClause)
        }
        else if
            let decl:EnumDeclSyntax = decl.as(EnumDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.enumKeyword
            self.encoder[at: .toplevel] += decl.name.trimmedPreservingLocation
            self.encode(decl.genericParameterClause)
        }
        else if
            let decl:ProtocolDeclSyntax = decl.as(ProtocolDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.protocolKeyword
            self.encoder[at: .toplevel] += decl.name.trimmedPreservingLocation
            self.encoder ?= decl.primaryAssociatedTypeClause?.trimmedPreservingLocation
        }
        else if
            let decl:StructDeclSyntax = decl.as(StructDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.structKeyword
            self.encoder[at: .toplevel] += decl.name.trimmedPreservingLocation
            self.encode(decl.genericParameterClause)
        }
        else if
            let decl:DeinitializerDeclSyntax = decl.as(DeinitializerDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder[at: .toplevel] += decl.deinitKeyword
            self.encoder ?= decl.effectSpecifiers?.trimmedPreservingLocation
        }
        else if
            let decl:FunctionDeclSyntax = decl.as(FunctionDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.funcKeyword
            self.encoder[at: .toplevel] += decl.name.trimmedPreservingLocation
            self.encode(decl.genericParameterClause)
            self.encode(decl.signature)
        }
        else if
            let decl:InitializerDeclSyntax = decl.as(InitializerDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder[at: .toplevel] += decl.initKeyword
            self.encoder ?= decl.optionalMark
            self.encode(decl.genericParameterClause)
            self.encode(decl.signature)
        }
        else if
            let decl:MacroDeclSyntax = decl.as(MacroDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.macroKeyword
            self.encoder[at: .toplevel] += decl.name.trimmedPreservingLocation
            self.encode(decl.genericParameterClause)
            self.encode(decl.signature)
        }
        else if
            let decl:SubscriptDeclSyntax = decl.as(SubscriptDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder[at: .toplevel] += decl.subscriptKeyword
            self.encode(decl.genericParameterClause)

            self.register(parameters: decl.parameterClause, type: .subscript)
            self.encoder += decl.returnClause.trimmedPreservingLocation
        }
        else if
            let decl:TypeAliasDeclSyntax = decl.as(TypeAliasDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.typealiasKeyword
            self.encoder[at: .toplevel] += decl.name.trimmedPreservingLocation
            self.encode(decl.genericParameterClause)
        }
        else if
            let decl:VariableDeclSyntax = decl.as(VariableDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.bindingSpecifier
            for binding:PatternBindingSyntax in decl.bindings
            {
                self.encoder[at: .toplevel] += binding.pattern.trimmedPreservingLocation
                self.encoder ?= binding.typeAnnotation?.trimmedPreservingLocation
                break
            }
        }
        else if
            let decl:EnumCaseDeclSyntax = decl.as(EnumCaseDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.caseKeyword
            for element:EnumCaseElementSyntax in decl.elements
            {
                self.encoder[at: .toplevel] += element.name.trimmedPreservingLocation

                if  let payload:EnumCaseParameterClauseSyntax = element.parameterClause
                {
                    self.encoder += payload.leftParen
                    for parameter:EnumCaseParameterSyntax in payload.parameters
                    {
                        self.encode(parameter.modifiers)
                        if  let label:TokenSyntax = parameter.firstName,
                                label.tokenKind != .wildcard
                        {
                            self.encoder[at: .toplevel] += label.trimmedPreservingLocation
                            self.encoder ?= parameter.colon
                        }
                        self.encoder += parameter.type.trimmedPreservingLocation
                        self.encoder ?= parameter.trailingComma
                    }
                    self.encoder += payload.rightParen.trimmedPreservingLocation
                }
                break
            }
        }
        else
        {
            fatalError("unsupported declaration: \(decl)")
        }
    }

    private mutating
    func encode(_ function:FunctionSignatureSyntax)
    {
        if  let returns:ReturnClauseSyntax = function.returnClause
        {
            self.register(parameters: function.parameterClause, type: .func)
            self.encoder ?= function.effectSpecifiers
            self.encoder += returns.trimmedPreservingLocation
        }
        else if
            let effects:FunctionEffectSpecifiersSyntax = function.effectSpecifiers
        {
            self.register(parameters: function.parameterClause, type: .func)
            self.encoder += effects.trimmedPreservingLocation
        }
        else
        {
            self.register(parameters: function.parameterClause, type: .func, trimAfter: true)
        }
    }

    private mutating
    func encode(_ modifiers:DeclModifierListSyntax)
    {
        for modifier:DeclModifierSyntax in modifiers
        {
            switch modifier.name.tokenKind
            {
            case    .keyword(.async),
                    .keyword(.class),
                    .keyword(.nonisolated),
                    .keyword(.reasync),
                    .keyword(.static):
                self.encoder += modifier

            case _:
                continue
            }
        }
    }

    private mutating
    func encode(_ clause: GenericParameterClauseSyntax?)
    {
        guard
        let clause:GenericParameterClauseSyntax
        else
        {
            return
        }

        self.encoder += clause.leftAngle.trimmedPreservingLocation
        for parameter:GenericParameterSyntax in clause.parameters
        {
            self.encoder ?= parameter.specifier
            self.encoder += parameter.name.trimmedPreservingLocation
            self.encoder ?= parameter.trailingComma
        }
        self.encoder += clause.rightAngle.trimmedPreservingLocation
    }
}
