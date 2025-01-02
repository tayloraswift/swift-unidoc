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
    private mutating
    func register(parameters clause:FunctionParameterClauseSyntax, type:SignatureParameterType)
    {
        for region:Syntax in clause.children(viewMode: .sourceAccurate)
        {
            guard
            let parameters:FunctionParameterListSyntax =
                region.as(FunctionParameterListSyntax.self)
            else
            {
                self.encoder += region
                continue
            }

            defer
            {
                self.encoder.wbr(indent: false)
            }
            for parameter:FunctionParameterSyntax in parameters
            {
                self.encoder.wbr(indent: true)
                self.encoder += self.visitor.register(parameter: parameter, type: type)
            }
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
        if  let decl:FunctionDeclSyntax = decl.as(FunctionDeclSyntax.self),
            let returns:ReturnClauseSyntax = decl.signature.returnClause
        {
            self.visitor.register(returns: returns.type)
        }
        else if
            let decl:SubscriptDeclSyntax = decl.as(SubscriptDeclSyntax.self)
        {
            self.visitor.register(returns: decl.returnClause.type)
        }
        else if
            let decl:VariableDeclSyntax = decl.as(VariableDeclSyntax.self),
            let type:TypeSyntax = decl.bindings.first?.typeAnnotation?.type
        {
            self.visitor.register(returns: type)
        }

        for region:Syntax in decl.children(viewMode: .sourceAccurate)
        {
            if  let region:TokenSyntax = region.as(TokenSyntax.self)
            {
                //  Allows us to detect phylum keywords.
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
                //  Allows us to detect `class` modifier keywords.
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
            self.encoder[at: .toplevel] += decl.name.trimmed
            self.encode(decl.genericParameterClause?.trimmed)
        }
        else if
            let decl:AssociatedTypeDeclSyntax = decl.as(AssociatedTypeDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.associatedtypeKeyword
            self.encoder[at: .toplevel] += decl.name.trimmed
        }
        else if
            let decl:ClassDeclSyntax = decl.as(ClassDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.classKeyword
            self.encoder[at: .toplevel] += decl.name.trimmed
            self.encode(decl.genericParameterClause?.trimmed)
        }
        else if
            let decl:EnumDeclSyntax = decl.as(EnumDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.enumKeyword
            self.encoder[at: .toplevel] += decl.name.trimmed
            self.encode(decl.genericParameterClause?.trimmed)
        }
        else if
            let decl:ProtocolDeclSyntax = decl.as(ProtocolDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.protocolKeyword
            self.encoder[at: .toplevel] += decl.name.trimmed
            self.encoder ?= decl.primaryAssociatedTypeClause?.trimmed
        }
        else if
            let decl:StructDeclSyntax = decl.as(StructDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.structKeyword
            self.encoder[at: .toplevel] += decl.name.trimmed
            self.encode(decl.genericParameterClause?.trimmed)
        }
        else if
            let decl:DeinitializerDeclSyntax = decl.as(DeinitializerDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder[at: .toplevel] += decl.deinitKeyword
            self.encoder ?= decl.effectSpecifiers?.trimmed
        }
        else if
            let decl:FunctionDeclSyntax = decl.as(FunctionDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.funcKeyword
            self.encoder[at: .toplevel] += decl.name
            self.encode(decl.genericParameterClause?.trimmed)
            self.encode(decl.signature)
        }
        else if
            let decl:InitializerDeclSyntax = decl.as(InitializerDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder[at: .toplevel] += decl.initKeyword
            self.encoder ?= decl.optionalMark
            self.encode(decl.genericParameterClause?.trimmed)
            self.encode(decl.signature)
        }
        else if
            let decl:MacroDeclSyntax = decl.as(MacroDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.macroKeyword
            self.encoder[at: .toplevel] += decl.name
            self.encode(decl.genericParameterClause?.trimmed)
            self.encode(decl.signature)
        }
        else if
            let decl:SubscriptDeclSyntax = decl.as(SubscriptDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder[at: .toplevel] += decl.subscriptKeyword
            self.encode(decl.genericParameterClause?.trimmed)

            self.register(parameters: decl.parameterClause, type: .subscript)
            self.encoder += decl.returnClause.trimmed
        }
        else if
            let decl:TypeAliasDeclSyntax = decl.as(TypeAliasDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.typealiasKeyword
            self.encoder[at: .toplevel] += decl.name.trimmed
            self.encode(decl.genericParameterClause?.trimmed)
        }
        else if
            let decl:VariableDeclSyntax = decl.as(VariableDeclSyntax.self)
        {
            self.encode(decl.modifiers)
            self.encoder += decl.bindingSpecifier
            for binding:PatternBindingSyntax in decl.bindings
            {
                self.encoder[at: .toplevel] += binding.pattern.trimmed
                self.encoder ?= binding.typeAnnotation?.trimmed
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
                self.encoder[at: .toplevel] += element.name.trimmed

                if  let payload:EnumCaseParameterClauseSyntax = element.parameterClause
                {
                    self.encoder += payload.leftParen
                    for parameter:EnumCaseParameterSyntax in payload.parameters
                    {
                        self.encode(parameter.modifiers)
                        if  let label:TokenSyntax = parameter.firstName,
                                label.tokenKind != .wildcard
                        {
                            self.encoder[at: .toplevel] += label.trimmed
                            self.encoder ?= parameter.colon
                        }
                        self.encoder += parameter.type.trimmed
                        self.encoder ?= parameter.trailingComma
                    }
                    self.encoder += payload.rightParen.trimmed
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
            self.encoder += returns.trimmed
        }
        else if
            let effects:FunctionEffectSpecifiersSyntax = function.effectSpecifiers
        {
            self.register(parameters: function.parameterClause, type: .func)
            self.encoder += effects.trimmed
        }
        else
        {
            self.register(parameters: function.parameterClause.trimmed, type: .func)
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
    func encode(_ clause:GenericParameterClauseSyntax?)
    {
        guard
        let clause:GenericParameterClauseSyntax
        else
        {
            return
        }

        self.encoder += clause.leftAngle
        for parameter:GenericParameterSyntax in clause.parameters
        {
            self.encoder ?= parameter.eachKeyword
            self.encoder += parameter.name.trimmed
            self.encoder ?= parameter.trailingComma
        }
        self.encoder += clause.rightAngle
    }
}
