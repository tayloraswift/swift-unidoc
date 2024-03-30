import System

@available(*, deprecated, renamed: "SSGC.Workspace")
public
typealias Workspace = SSGC.Workspace

extension SSGC
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
