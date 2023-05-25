import ModuleGraphs
import System

@frozen public
struct RepositoryCheckout
{
    let workspace:Workspace
    let root:FilePath
    public
    let pin:Repository.Pin

    init(workspace:Workspace, root:FilePath, pin:Repository.Pin)
    {
        self.workspace = workspace
        self.root = root
        self.pin = pin
    }
}
