import HTTPServer
import UnidocPages

struct ConfirmOperation:Sendable
{
    let action:Site.Action

    init(_ action:Site.Action)
    {
        self.action = action
    }
}
extension ConfirmOperation:DatalessOperation
{
    func load() throws -> ServerResponse?
    {
        let page:Site.Admin.Confirm

        switch self.action
        {
        case .dropDatabase:
            page = .init(action: action,
                label: "Drop Database",
                text: """
                This will drop (and reinitialize) the entire database. Are you sure?
                """)

        case .rebuild, .upload:
            return nil
        }

        return .resource(page.rendered())
    }
}
