import System

@available(*, deprecated, renamed: "SPM.Workspace")
public
typealias Workspace = SPM.Workspace

extension SPM
{
    @frozen public
    struct Workspace:SystemWorkspace, Equatable
    {
        public
        let path:FilePath

        @inlinable public
        init(path:FilePath)
        {
            self.path = path
        }
    }
}
