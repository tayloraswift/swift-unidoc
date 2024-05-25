import HTML
import Media
import URI

extension Unidoc
{
    /// A basic confirmation page that displays a single-sentence prompt.
    struct ReallyPage
    {
        let title:String
        let prompt:String
        let button:String

        let action:URI

        init(title:String,
            prompt:String,
            button:String,
            action:URI)
        {
            self.title = title
            self.prompt = prompt
            self.button = button
            self.action = action
        }
    }
}
extension Unidoc.ReallyPage
{
    static
    func unlink(_ action:URI) -> Self
    {
        .init(title: "Unlink symbol graph?",
            prompt: """
            Nobody will be able to read the documentation for this version of the package. \
            You can reverse this action by uplinking the symbol graph again.
            """,
            button: "Remove documentation",
            action: action)
    }

    static
    func delete(_ action:URI) -> Self
    {
        .init(title: "Delete symbol graph?",
            prompt: """
            Nobody will be able to read the documentation for this version of the package. \
            This action is irreversible!
            """,
            button: "It is so ordered",
            action: action)
    }

    static
    func packageConfig(_ action:URI, update:Unidoc.PackageConfigOperation.Update) -> Self?
    {
        switch update
        {
        case .expires:
            return .init(title: "Refresh package tags?",
                prompt: """
                This package will be added to a priority crawl queue. \
                Submitting this form multiple times will not improve its queue position.
                """,
                button: "Refresh tags",
                action: action)

        case .hidden(true):
            return .init(title: "Hide package?",
                prompt: """
                The package will no longer appear in search, or in the activity feed. \
                This will not affect the package’s documentation.
                """,
                button: "Hide package",
                action: action)

        case .hidden(false):
            return nil

        case .symbol:
            return .init(title: "Rename package?",
                prompt: """
                This will not affect documentation that has already been generated.
                """,
                button: "Rename package",
                action: action)

        case .reset:
            return nil
        }
    }

    static
    func userConfig(_ action:URI, update:Unidoc.UserConfigOperation.Update) -> Self
    {
        switch update
        {
        case .generateKey:
            return .init(title: "Generate API key?",
                prompt: """
                This will invalidate any previously-generated API keys. \
                You cannot undo this action!
                """,
                button: "Generate key",
                action: action)
        }
    }
}
extension Unidoc.ReallyPage:Unidoc.ConfirmationPage
{
    func form(_ form:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        form[.p] = self.prompt
    }
}
