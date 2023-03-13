import Declarations
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "empty"
        {
            let declaration:Declaration<Never> = .init(expanded: [],
                abridged: [])
            
            tests.expect(declaration.identifiers ..? [])
            tests.expect(declaration.abridged ..? [])
            tests.expect(declaration.expanded ..? [])
            tests.expect(declaration.count ==? 0)
        }
        if  let tests:TestGroup = tests / "convergent"
        {
            let expanded:[DeclarationFragment<Never, DeclarationFragmentClass?>] =
            [
                .init("init", color: .keyword),
                .init("(", color: nil),
                .init("x", color: .label),
                .init(" ", color: nil),
                .init("y", color: .binding),
                .init(":", color: nil),
                .init("Int", color: .typeIdentifier),
                .init(")", color: nil),
            ]
            let declaration:Declaration<Never> = .init(expanded: expanded,
                abridged:
                [
                    .init("init", color: .keyword),
                    .init("(", color: nil),
                    .init("x", color: .label),
                    .init(":", color: nil),
                    .init("Int", color: .typeIdentifier),
                    .init(")", color: nil),
                ])

            tests.expect(declaration.identifiers ..?
            [
                .init("init", color: nil),
                .init("x", color: nil),
            ])
            tests.expect(declaration.abridged ..?
            [
                .init("init", color: true),
                .init("(", color: false),
                .init("x", color: true),
                .init(":", color: false),
                .init("Int", color: false),
                .init(")", color: false),
            ])
            tests.expect(declaration.expanded ..? expanded)
            tests.expect(declaration.count ==? expanded.count)
        }
        if  let tests:TestGroup = tests / "attributes"
        {
            let expanded:[DeclarationFragment<Never, DeclarationFragmentClass?>] =
            [
                .init("@inlinable", color: .attribute),
                .init(" ", color: nil),
                .init("init", color: .keyword),
                .init("(", color: nil),
                .init(")", color: nil),
            ]
            let declaration:Declaration<Never> = .init(expanded: expanded,
                abridged:
                [
                    .init("init", color: .keyword),
                    .init("(", color: nil),
                    .init(")", color: nil),
                ])

            tests.expect(declaration.identifiers ..?
            [
                .init("init", color: nil),
            ])
            tests.expect(declaration.abridged ..?
            [
                .init("init", color: true),
                .init("(", color: false),
                .init(")", color: false),
            ])
            tests.expect(declaration.expanded ..? expanded)
            tests.expect(declaration.count ==? expanded.count)
        }
        if  let tests:TestGroup = tests / "divergent" / "middle"
        {
            let expanded:[DeclarationFragment<Never, DeclarationFragmentClass?>] =
            [
                .init("init", color: .keyword),
                .init("(", color: nil),
                .init("x", color: .label),
                .init(":__shared ", color: nil),
                .init("Int", color: .typeIdentifier),
                .init(") ", color: nil),
            ]
            let declaration:Declaration<Never> = .init(expanded: expanded,
                abridged:
                [
                    .init("init", color: .keyword),
                    .init("(", color: nil),
                    .init("x", color: .label),
                    .init(":", color: nil),
                    .init("Int", color: .typeIdentifier),
                    .init(")", color: nil),
                ])

            tests.expect(declaration.identifiers ..?
            [
                .init("init", color: nil),
                .init("x", color: nil),
            ])
            tests.expect(declaration.abridged ..?
            [
                .init("init", color: true),
                .init("(", color: false),
                .init("x", color: true),
                .init(":", color: false),
                .init("Int", color: false),
                .init(")", color: false),
            ])
            tests.expect(declaration.expanded ..? expanded)
            //  Three extra fragments, because the interior divergent fragment
            //  inhibits all further matching.
            tests.expect(declaration.count ==? expanded.count + 3)
        }
        if  let tests:TestGroup = tests / "divergent" / "end"
        {
            let expanded:[DeclarationFragment<Never, DeclarationFragmentClass?>] =
            [
                .init("init", color: .keyword),
                .init("(", color: nil),
                .init(") ", color: nil),
                .init("where", color: .keyword),
                .init(" ", color: nil),
                .init("T", color: .typeIdentifier),
                .init(":", color: nil),
                .init("AnyObject", color: .keyword),
            ]
            let declaration:Declaration<Never> = .init(expanded: expanded,
                abridged:
                [
                    .init("init", color: .keyword),
                    .init("(", color: nil),
                    .init(")", color: nil),
                ])

            tests.expect(declaration.identifiers ..?
            [
                .init("init", color: nil),
            ])
            tests.expect(declaration.abridged ..?
            [
                .init("init", color: true),
                .init("(", color: false),
                .init(")", color: false),
            ])
            tests.expect(declaration.expanded ..? expanded)
            tests.expect(declaration.count ==? expanded.count + 1)
        }
    }
}
