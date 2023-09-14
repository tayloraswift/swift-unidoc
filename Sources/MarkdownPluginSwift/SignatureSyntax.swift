
import IDEUtils
import MarkdownABI
import SwiftParser
import SwiftSyntax

@frozen @usableFromInline internal
struct SignatureSyntax
{
    @usableFromInline internal
    var elements:[Span]

    private
    init()
    {
        self.elements = []
    }
}
extension SignatureSyntax
{
    @usableFromInline internal
    init(utf8:UnsafeBufferPointer<UInt8>)
    {
        self.init()

        var parser:Parser = .init(utf8)

        let decl:DeclSyntax = .parse(from: &parser)

        for region:Syntax in decl.children(viewMode: .sourceAccurate)
        {
            if  let region:TokenSyntax = region.as(TokenSyntax.self)
            {
                //  Allows us to detect phylum keywords.
                self.append(region: region, at: .toplevel)
            }
            else if
                let region:ModifierListSyntax = region.as(ModifierListSyntax.self)
            {
                //  Allows us to detect `class` modifier keywords.
                self.append(region: region, at: .toplevel)
            }
            else if
                let clause:GenericParameterClauseSyntax =
                    region.as(GenericParameterClauseSyntax.self)
            {
                self.append(clause: clause)
            }
            else if
                let region:FunctionSignatureSyntax = region.as(FunctionSignatureSyntax.self)
            {
                for region:Syntax in region.children(viewMode: .sourceAccurate)
                {
                    if  let clause:ParameterClauseSyntax =
                            region.as(ParameterClauseSyntax.self)
                    {
                        self.append(clause: clause)
                    }
                    else if
                        let region:ReturnClauseSyntax =
                            region.as(ReturnClauseSyntax.self)
                    {
                        self.append(region: region)
                    }
                    else
                    {
                        self.append(region: region)
                    }
                }
            }
            else if
                let clause:ParameterClauseSyntax = region.as(ParameterClauseSyntax.self)
            {
                self.append(clause: clause)
            }
            else
            {
                self.append(region: region)
            }
        }
    }
}
extension SignatureSyntax
{
    private mutating
    func append(region syntax:some SyntaxProtocol, at depth:Span.Depth? = nil)
    {
        for span:SyntaxClassifiedRange in syntax.classifications
        {
            let range:Range<Int> = span.offset ..< span.offset + span.length

            self.elements.append(.text(range, .init(classification: span.kind), depth))
        }
    }

    private mutating
    func append(region syntax:some SyntaxProtocol, as color:MarkdownBytecode.Context)
    {
        for span:SyntaxClassifiedRange in syntax.classifications
        {
            let range:Range<Int> = span.offset ..< span.offset + span.length
            self.elements.append(.text(range, span.kind == .none ? nil : color))
        }
    }
}
extension SignatureSyntax
{
    private mutating
    func append(clause region:GenericParameterClauseSyntax)
    {
        for region:Syntax in region.children(viewMode: .sourceAccurate)
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
                            self.append(region: region, as: .typealias)
                        }
                        else
                        {
                            self.append(region: region)
                        }
                    }
                }
            }
            else
            {
                self.append(region: region)
            }
        }
    }
    private mutating
    func append(clause region:ParameterClauseSyntax)
    {
        for region:Syntax in region.children(viewMode: .sourceAccurate)
        {
            if  let region:FunctionParameterListSyntax =
                    region.as(FunctionParameterListSyntax.self)
            {
                defer
                {
                    self.elements.append(.wbr(indent: false))
                }
                for region:FunctionParameterSyntax in region
                {
                    self.elements.append(.wbr(indent: true))

                    var named:Bool = false
                    for region:Syntax in region.children(viewMode: .sourceAccurate)
                    {
                        guard
                        let region:TokenSyntax = region.as(TokenSyntax.self)
                        else
                        {
                            self.append(region: region)
                            continue
                        }

                        switch region.tokenKind
                        {
                        case .identifier, .wildcardKeyword:
                            if  named
                            {
                                self.append(region: region, as: .binding)
                            }
                            else
                            {
                                self.append(region: region, as: .identifier)
                                named = true
                            }

                        case _:
                            self.append(region: region)
                        }
                    }
                }
            }
            else
            {
                self.append(region: region)
            }
        }
    }
}
