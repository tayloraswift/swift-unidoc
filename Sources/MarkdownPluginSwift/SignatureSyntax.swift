
import MarkdownABI
import SwiftIDEUtils
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
    private
    init(utf8:UnsafeBufferPointer<UInt8>, abridged:Bool)
    {
        self.init()

        var parser:Parser = .init(utf8)

        let decl:DeclSyntax = .parse(from: &parser)

        for region:Syntax in decl.children(viewMode: .sourceAccurate)
        {
            if  let region:TokenSyntax = region.as(TokenSyntax.self)
            {
                //  Allows us to detect phylum keywords.
                self.append(region: region, offset: 0, at: .toplevel)
            }
            else if
                let region:AttributeListSyntax = region.as(AttributeListSyntax.self)
            {
                self.append(region: region, offset: 0, at: .toplevel)
            }
            else if
                let region:DeclModifierListSyntax = region.as(DeclModifierListSyntax.self)
            {
                //  Allows us to detect `class` modifier keywords.
                self.append(region: region, offset: 0, at: .toplevel)
            }
            else if
                let clause:GenericParameterClauseSyntax =
                    region.as(GenericParameterClauseSyntax.self)
            {
                self.append(generics: clause)
            }
            else if
                let region:FunctionSignatureSyntax = region.as(FunctionSignatureSyntax.self)
            {
                for region:Syntax in region.children(viewMode: .sourceAccurate)
                {
                    if  let clause:FunctionParameterClauseSyntax =
                            region.as(FunctionParameterClauseSyntax.self)
                    {
                        self.append(parameters: clause, abridged: abridged)
                    }
                    else if
                        let region:ReturnClauseSyntax =
                            region.as(ReturnClauseSyntax.self)
                    {
                        self.append(region: region, offset: 0)
                    }
                    else
                    {
                        self.append(region: region, offset: 0)
                    }
                }
            }
            else if
                let clause:FunctionParameterClauseSyntax =
                    region.as(FunctionParameterClauseSyntax.self)
            {
                self.append(parameters: clause, abridged: abridged)
            }
            else
            {
                self.append(region: region, offset: 0)
            }
        }
    }
}
extension SignatureSyntax
{
    @usableFromInline internal static
    func abridged(_ utf8:UnsafeBufferPointer<UInt8>) -> Self
    {
        .init(utf8: utf8, abridged: true)
    }
    @usableFromInline internal static
    func expanded(_ utf8:UnsafeBufferPointer<UInt8>) -> Self
    {
        .init(utf8: utf8, abridged: false)
    }
}
extension SignatureSyntax
{
    private mutating
    func append(
        region syntax:some SyntaxProtocol,
        offset:Int,
        at depth:Span.Depth? = nil)
    {
        for span:SyntaxClassifiedRange in syntax.classifications
        {
            let range:Range<Int> =
                offset + span.offset ..<
                offset + span.offset + span.length

            self.elements.append(.text(range, .init(classification: span.kind), depth))
        }
    }

    private mutating
    func append(
        region syntax:some SyntaxProtocol,
        offset:Int,
        as color:MarkdownBytecode.Context)
    {
        for span:SyntaxClassifiedRange in syntax.classifications
        {
            let range:Range<Int> =
                offset + span.offset ..<
                offset + span.offset + span.length

            self.elements.append(.text(range, span.kind == .none ? nil : color))
        }
    }
}
extension SignatureSyntax
{
    private mutating
    func append(generics clause:GenericParameterClauseSyntax)
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
                            self.append(region: region, offset: 0, as: .typealias)
                        }
                        else
                        {
                            self.append(region: region, offset: 0)
                        }
                    }
                }
            }
            else
            {
                self.append(region: region, offset: 0)
            }
        }
    }
    private mutating
    func append(parameters region:FunctionParameterClauseSyntax, abridged:Bool)
    {
        if  abridged
        {
            var reparser:Parser = .init("\(region)")

            let tuple:TypeSyntax = .parse(from: &reparser)
            guard
            let tuple:TupleTypeSyntax = tuple.as(TupleTypeSyntax.self)
            else
            {
                fatalError("not a tuple type!")
            }

            self.append(parameters: tuple,
                offset: region.position.utf8Offset,
                as: TupleTypeElementListSyntax.self)

        }
        else
        {
            self.append(parameters: region,
                offset: 0,
                as: FunctionParameterListSyntax.self)
        }
    }
    private mutating
    func append<ParameterListSyntax>(
        parameters:some SyntaxProtocol,
        offset:Int,
        as _:ParameterListSyntax.Type)
        where ParameterListSyntax:SyntaxCollection
    {
        for region:Syntax in parameters.children(viewMode: .sourceAccurate)
        {
            if  let region:ParameterListSyntax =
                    region.as(ParameterListSyntax.self)
            {
                defer
                {
                    self.elements.append(.wbr(indent: false))
                }
                for region:ParameterListSyntax.Element in region
                {
                    self.elements.append(.wbr(indent: true))

                    var named:Bool = false
                    for region:Syntax in region.children(viewMode: .sourceAccurate)
                    {
                        guard
                        let region:TokenSyntax = region.as(TokenSyntax.self)
                        else
                        {
                            self.append(region: region, offset: offset)
                            continue
                        }

                        switch region.tokenKind
                        {
                        case .identifier, .wildcard:
                            if  named
                            {
                                self.append(region: region, offset: offset, as: .binding)
                            }
                            else
                            {
                                self.append(region: region, offset: offset, as: .identifier)
                                named = true
                            }

                        case _:
                            self.append(region: region, offset: offset)
                        }
                    }
                }
            }
            else
            {
                self.append(region: region, offset: offset)
            }
        }
    }
}
