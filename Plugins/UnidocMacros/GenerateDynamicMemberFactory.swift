import SwiftSyntax
import SwiftSyntaxMacros

extension TokenSyntax
{
    var unescaped:Substring
    {
        let text:String = self.text

        if  let first:String.Index = text.indices.first,
            let last:String.Index = text.indices.last,
                last != first,
                text[first] == "`",
                text[last] == "`"
        {
            return text[text.index(after: first) ..< last]
        }
        else
        {
            return text[...]
        }
    }
}

public
struct GenerateDynamicMemberFactory
{
    private
    let subject:TokenSyntax

    private
    var members:[MemberBlockItemSyntax]
    private(set)
    var exclude:[Substring: StringLiteralExprSyntax]


    init(for subject:TokenSyntax)
    {
        let initializer:DeclSyntax = """
        @inlinable internal init() {}
        """

        self.members = [.init(decl: initializer)]
        self.exclude = [:]

        self.subject = subject
    }
}
extension GenerateDynamicMemberFactory
{
    mutating
    func exclude(_ literal:StringLiteralExprSyntax)
    {
        self.exclude["\(literal.segments)"] = literal
    }

    mutating
    func append(_ case:EnumCaseElementSyntax)
    {
        if  case _? = self.exclude.removeValue(forKey: `case`.name.unescaped)
        {
            return
        }

        let decl:DeclSyntax = """
        @inlinable public var \(`case`.name):\(self.subject) { .\(`case`.name) }
        """

        self.members.append(.init(decl: decl))
    }

    consuming
    func factory(named name:TokenSyntax) -> DeclSyntax
    {
        """
        @frozen public
        struct \(name)
        {
            \(MemberBlockItemListSyntax.init(self.members))
        }
        """
    }
}
extension GenerateDynamicMemberFactory:MemberMacro
{
    public static
    func expansion(of attachment:AttributeSyntax,
        providingMembersOf decl:some DeclGroupSyntax,
        in context:some MacroExpansionContext) throws -> [DeclSyntax]
    {
        guard
        let decl:EnumDeclSyntax = .init(decl)
        else
        {
            context[.error, decl] = """
            macro can only be applied to an enum
            """
            return []
        }

        var generator:Self = .init(for: decl.name)
        if  case .argumentList(let arguments)? = attachment.arguments
        {
            for argument:LabeledExprSyntax in arguments
            {
                if  let value:StringLiteralExprSyntax = .init(argument.expression)
                {
                    generator.exclude(value)
                }
            }
        }

        for item:MemberBlockItemSyntax in decl.memberBlock.members
        {
            guard
            let cases:EnumCaseDeclSyntax = .init(item.decl)
            else
            {
                continue
            }

            for `case`:EnumCaseElementSyntax in cases.elements
            {
                generator.append(`case`)
            }
        }

        let type:DeclSyntax = generator.factory(named: .identifier("Factory"))

        for (lint, node):(Substring, StringLiteralExprSyntax) in
            generator.exclude.sorted(by: { $0.key < $1.key })
        {
            context[.warning, node] = """
            '\(lint)' is not a case of '\(decl.name.unescaped)'
            """
        }

        return [type]
    }
}
