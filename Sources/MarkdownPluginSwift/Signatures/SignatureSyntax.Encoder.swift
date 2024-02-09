import MarkdownABI
import SwiftIDEUtils
import SwiftSyntax

extension SignatureSyntax
{
    struct Encoder<ParameterFormat>:~Copyable where ParameterFormat:SignatureParameterFormat
    {
        private
        var spans:[Span]

        /// An override for the color of the next span.
        private
        var color:MarkdownBytecode.Context?
        /// The depth level used to encode the next span.
        private
        var depth:Span.Depth?

        init(spans:[Span] = [],
            color:MarkdownBytecode.Context? = nil,
            depth:Span.Depth? = nil)
        {
            self.spans = spans
            self.color = color
            self.depth = depth
        }
    }
}
extension SignatureSyntax.Encoder
{
    consuming
    func move() -> [SignatureSyntax.Span] { self.spans }

    mutating
    func wbr(indent:Bool)
    {
        self.spans.append(.wbr(indent: indent))
    }
}
extension SignatureSyntax.Encoder
{
    subscript(in color:MarkdownBytecode.Context) -> Self
    {
        get
        {
            .init(spans: self.spans,
                color: color,
                depth: self.depth)
        }
        _modify
        {
            let outer:MarkdownBytecode.Context? = self.color
            self.color = color
            defer { self.color = outer }

            yield &self
        }
    }
    subscript(at depth:SignatureSyntax.Span.Depth) -> Self
    {
        get
        {
            .init(spans: self.spans,
                color: self.color,
                depth: depth)
        }
        _modify
        {
            let outer:SignatureSyntax.Span.Depth? = self.depth
            self.depth = depth
            defer { self.depth = outer }

            yield &self
        }
    }
}
extension SignatureSyntax.Encoder
{
    static
    func ?= (self:inout Self, syntax:(some SyntaxProtocol)?)
    {
        syntax.map { self += $0 }
    }
    static
    func += (self:inout Self, syntax:some SyntaxProtocol)
    {
        for span:SyntaxClassifiedRange in syntax.classifications
        {
            let range:Range<Int> = span.offset ..< span.offset + span.length
            let color:MarkdownBytecode.Context? = .init(classification: span.kind)

            self.spans.append(.text(range, color.map { self.color ?? $0 }, self.depth))
        }
    }
}
extension SignatureSyntax.Encoder
{
    static
    func += (self:inout Self, clause:(syntax:FunctionParameterClauseSyntax, func:Bool))
    {
        for region:Syntax in clause.syntax.children(viewMode: .sourceAccurate)
        {
            guard
            let parameters:FunctionParameterListSyntax =
                region.as(FunctionParameterListSyntax.self)
            else
            {
                self += region
                continue
            }

            defer
            {
                self.wbr(indent: false)
            }
            for parameter:FunctionParameterSyntax in parameters
            {
                self.wbr(indent: true)

                self += ParameterFormat.init(syntax: parameter, func: clause.func)
            }
        }
    }
}

extension SignatureSyntax.Encoder<SignatureSyntax.ExpandedParameter>
{
    static
    func += (self:inout Self, decl:DeclSyntax)
    {
        for region:Syntax in decl.children(viewMode: .sourceAccurate)
        {
            if  let region:TokenSyntax = region.as(TokenSyntax.self)
            {
                //  Allows us to detect phylum keywords.
                self[at: .toplevel] += region
            }
            else if
                let region:AttributeListSyntax = region.as(AttributeListSyntax.self)
            {
                self[at: .toplevel] += region
            }
            else if
                let region:DeclModifierListSyntax = region.as(DeclModifierListSyntax.self)
            {
                //  Allows us to detect `class` modifier keywords.
                self[at: .toplevel] += region
            }
            else if
                let clause:GenericParameterClauseSyntax =
                    region.as(GenericParameterClauseSyntax.self)
            {
                self += clause
            }
            else if
                let region:FunctionSignatureSyntax = region.as(FunctionSignatureSyntax.self)
            {
                for region:Syntax in region.children(viewMode: .sourceAccurate)
                {
                    if  let clause:FunctionParameterClauseSyntax =
                            region.as(FunctionParameterClauseSyntax.self)
                    {
                        self += (clause, func: true)
                    }
                    else if
                        let region:ReturnClauseSyntax =
                            region.as(ReturnClauseSyntax.self)
                    {
                        self += region
                    }
                    else
                    {
                        self += region
                    }
                }
            }
            else if
                let clause:FunctionParameterClauseSyntax =
                    region.as(FunctionParameterClauseSyntax.self)
            {
                self += (clause, func: false)
            }
            else
            {
                self += region
            }
        }
    }

    static
    func += (self:inout Self, clause:GenericParameterClauseSyntax)
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
                            self[in: .typealias] += region
                        }
                        else
                        {
                            self += region
                        }
                    }
                }
            }
            else
            {
                self += region
            }
        }
    }
}

extension SignatureSyntax.Encoder<SignatureSyntax.AbridgedParameter>
{
    static
    func += (self:inout Self, decl:DeclSyntax)
    {
        if  let decl:ActorDeclSyntax = decl.as(ActorDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.actorKeyword
            self[at: .toplevel] += decl.name.trimmed
            self ?= decl.genericParameterClause?.trimmed
        }
        else if
            let decl:AssociatedTypeDeclSyntax = decl.as(AssociatedTypeDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.associatedtypeKeyword
            self[at: .toplevel] += decl.name.trimmed
        }
        else if
            let decl:ClassDeclSyntax = decl.as(ClassDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.classKeyword
            self[at: .toplevel] += decl.name.trimmed
            self ?= decl.genericParameterClause?.trimmed
        }
        else if
            let decl:EnumDeclSyntax = decl.as(EnumDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.enumKeyword
            self[at: .toplevel] += decl.name.trimmed
            self ?= decl.genericParameterClause?.trimmed
        }
        else if
            let decl:ProtocolDeclSyntax = decl.as(ProtocolDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.protocolKeyword
            self[at: .toplevel] += decl.name.trimmed
            self ?= decl.primaryAssociatedTypeClause?.trimmed
        }
        else if
            let decl:StructDeclSyntax = decl.as(StructDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.structKeyword
            self[at: .toplevel] += decl.name.trimmed
            self ?= decl.genericParameterClause?.trimmed
        }
        else if
            let decl:DeinitializerDeclSyntax = decl.as(DeinitializerDeclSyntax.self)
        {
            self += decl.modifiers
            self[at: .toplevel] += decl.deinitKeyword
            self ?= decl.effectSpecifiers?.trimmed
        }
        else if
            let decl:FunctionDeclSyntax = decl.as(FunctionDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.funcKeyword
            self[at: .toplevel] += decl.name
            self ?= decl.genericParameterClause
            self += decl.signature
        }
        else if
            let decl:InitializerDeclSyntax = decl.as(InitializerDeclSyntax.self)
        {
            self += decl.modifiers
            self[at: .toplevel] += decl.initKeyword
            self ?= decl.optionalMark
            self ?= decl.genericParameterClause
            self += decl.signature
        }
        else if
            let decl:MacroDeclSyntax = decl.as(MacroDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.macroKeyword
            self[at: .toplevel] += decl.name
            self ?= decl.genericParameterClause
            self += decl.signature
        }
        else if
            let decl:SubscriptDeclSyntax = decl.as(SubscriptDeclSyntax.self)
        {
            self += decl.modifiers
            self[at: .toplevel] += decl.subscriptKeyword
            self ?= decl.genericParameterClause
            self += (decl.parameterClause, func: false)
            self ?= decl.returnClause.trimmed
        }
        else if
            let decl:TypeAliasDeclSyntax = decl.as(TypeAliasDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.typealiasKeyword
            self[at: .toplevel] += decl.name.trimmed
            self ?= decl.genericParameterClause?.trimmed
        }
        else if
            let decl:VariableDeclSyntax = decl.as(VariableDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.bindingSpecifier
            for binding:PatternBindingSyntax in decl.bindings
            {
                self[at: .toplevel] += binding.pattern.trimmed
                self ?= binding.typeAnnotation?.trimmed
                break
            }
        }
        else if
            let decl:EnumCaseDeclSyntax = decl.as(EnumCaseDeclSyntax.self)
        {
            self += decl.modifiers
            self += decl.caseKeyword
            for element:EnumCaseElementSyntax in decl.elements
            {
                self[at: .toplevel] += element.name.trimmed

                if  let payload:EnumCaseParameterClauseSyntax = element.parameterClause
                {
                    self += payload.leftParen
                    for parameter:EnumCaseParameterSyntax in payload.parameters
                    {
                        self += parameter.modifiers
                        if  let label:TokenSyntax = parameter.firstName,
                                label.tokenKind != .wildcard
                        {
                            self[at: .toplevel] += label.trimmed
                            self ?= parameter.colon
                        }
                        self += parameter.type.trimmed
                        self ?= parameter.trailingComma
                    }
                    self += payload.rightParen.trimmed
                }
                break
            }
        }
        else
        {
            fatalError("unsupported declaration: \(decl)")
        }
    }

    static
    func += (self:inout Self, function:FunctionSignatureSyntax)
    {
        if  let returns:ReturnClauseSyntax = function.returnClause
        {
            self += (function.parameterClause, func: true)
            self ?= function.effectSpecifiers
            self += returns.trimmed
        }
        else if
            let effects:FunctionEffectSpecifiersSyntax = function.effectSpecifiers
        {
            self += (function.parameterClause, func: true)
            self += effects.trimmed
        }
        else
        {
            self += (function.parameterClause.trimmed, func: true)
        }
    }

    static
    func += (self:inout Self, modifiers:DeclModifierListSyntax)
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
                self += modifier

            case _:
                continue
            }
        }
    }

    static
    func ?= (self:inout Self, clause:GenericParameterClauseSyntax?)
    {
        clause.map { self += $0 }
    }
    static
    func += (self:inout Self, clause:GenericParameterClauseSyntax)
    {
        self += clause.leftAngle
        for parameter:GenericParameterSyntax in clause.parameters
        {
            self ?= parameter.eachKeyword
            self += parameter.name.trimmed
            self ?= parameter.trailingComma
        }
        self += clause.rightAngle
    }
}
