import System

extension SPM
{
    @frozen public
    struct ArtifactDirectory:SystemWorkspace
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
