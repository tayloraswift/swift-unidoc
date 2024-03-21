import SwiftSyntax
import SwiftSyntaxMacros

public
struct GenerateCasesByIntegerEncoding
{
    private
    var constructors:[MemberBlockItemSyntax]

    init()
    {
        self.constructors = []
    }
}
extension GenerateCasesByIntegerEncoding
{
    mutating
    func append(_ case:EnumCaseElementSyntax)
    {
        let hex:String = "\(`case`.name)".utf8.reduce(into: "")
        {
            //  Ignore backticks
            guard $1 != 0x60
            else
            {
                return
            }

            $0 += String.init($1 >> 4,   radix: 16)
            $0 += String.init($1 & 0x0F, radix: 16)
        }

        let decl:DeclSyntax = """
        @inlinable public static
        var \(`case`.name):Self { .init(rawValue: 0x\(raw: hex)) }
        """

        self.constructors.append(.init(decl: decl))
    }

    consuming
    func block(extending subject:some TypeSyntaxProtocol) -> ExtensionDeclSyntax
    {
        .init(extendedType: subject,
            memberBlock: .init(members: .init(constructors)))
    }
}
extension GenerateCasesByIntegerEncoding:ExtensionMacro
{
    public static
    func expansion(of attachment:AttributeSyntax,
        attachedTo declaration:some DeclGroupSyntax,
        providingExtensionsOf subject:some TypeSyntaxProtocol,
        conformingTo protocols:[TypeSyntax],
        in context:some MacroExpansionContext) throws -> [ExtensionDeclSyntax]
    {
        if  let missing:TypeSyntax = protocols.first
        {
            context[.error, attachment] = """
            macro must be applied to a type that conforms to '\(missing)'
            """
            return []
        }

        let name:String = "AvailableCases"

        var cases:EnumDeclSyntax? = nil
        for item:MemberBlockItemSyntax in declaration.memberBlock.members
        {
            if  let decl:EnumDeclSyntax = .init(item.decl),
                    decl.name.text == name
            {
                cases = decl
                break
            }
        }

        guard
        let cases:EnumDeclSyntax
        else
        {
            context[.error, declaration] = """
            macro must be applied to a declaration block containing an enum named '\(name)'
            """
            return []
        }

        var generator:Self = .init()
        for cases:MemberBlockItemSyntax in cases.memberBlock.members
        {
            guard
            let cases:EnumCaseDeclSyntax = .init(cases.decl)
            else
            {
                continue
            }

            for `case`:EnumCaseElementSyntax in cases.elements
            {
                generator.append(`case`)
            }
        }

        return [generator.block(extending: subject)]
    }
}
