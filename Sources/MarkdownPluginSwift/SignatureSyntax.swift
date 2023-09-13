
import IDEUtils
import MarkdownABI
import SwiftParser
import SwiftSyntax

@frozen @usableFromInline internal
struct SignatureSyntax
{
    @usableFromInline internal
    var tokens:[Token?]

    private
    init()
    {
        self.tokens = []
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

        for region:Syntax in decl.children(viewMode: .fixedUp)
        {
            if  let clause:GenericParameterClauseSyntax =
                    region.as(GenericParameterClauseSyntax.self)
            {
                self.append(clause: clause)
            }
            else if
                let region:FunctionSignatureSyntax = region.as(FunctionSignatureSyntax.self)
            {
                for region:Syntax in region.children(viewMode: .fixedUp)
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
    func append(region syntax:some SyntaxProtocol)
    {
        for span:SyntaxClassifiedRange in syntax.classifications
        {
            let range:Range<Int> = span.offset ..< span.offset + span.length

            self.tokens.append(.init(range: range,
                color: .init(classification: span.kind)))
        }
    }

    private mutating
    func append(region syntax:some SyntaxProtocol, as color:MarkdownBytecode.Context)
    {
        for span:SyntaxClassifiedRange in syntax.classifications
        {
            let range:Range<Int> = span.offset ..< span.offset + span.length
            if  case .none = span.kind
            {
                self.tokens.append(.init(range: range, color: nil))
            }
            else
            {
                self.tokens.append(.init(range: range, color: color))
            }
        }
    }
}
extension SignatureSyntax
{
    private mutating
    func append(clause region:GenericParameterClauseSyntax)
    {
        for region:Syntax in region.children(viewMode: .fixedUp)
        {
            if  let region:GenericParameterListSyntax =
                    region.as(GenericParameterListSyntax.self)
            {
                for region:GenericParameterSyntax in region
                {
                    for region:Syntax in region.children(viewMode: .fixedUp)
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
        for region:Syntax in region.children(viewMode: .fixedUp)
        {
            if  let region:FunctionParameterListSyntax =
                    region.as(FunctionParameterListSyntax.self)
            {
                var first:Bool = true
                for region:FunctionParameterSyntax in region
                {
                    if  first
                    {
                        self.tokens.append(nil)
                        first = false
                    }
                    defer
                    {
                        self.tokens.append(nil)
                    }

                    var firstName:Bool = true
                    for region:Syntax in region.children(viewMode: .fixedUp)
                    {
                        if  firstName,
                            let region:TokenSyntax = region.as(TokenSyntax.self)
                        {
                            switch region.tokenKind
                            {
                            case .identifier, .wildcardKeyword:
                                self.append(region: region, as: .label)
                                firstName = false

                            case _:
                                self.append(region: region)
                            }
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
}
