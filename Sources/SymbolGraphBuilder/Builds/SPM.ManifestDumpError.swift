import PackageMetadata
import System
import TraceableErrors

extension SPM
{
    public
    struct ManifestDumpError:Error
    {
        public
        let underlying:any Error
        public
        let root:FilePath

        public
        init(underlying:any Error, root:FilePath)
        {
            self.underlying = underlying
            self.root = root
        }
    }
}
extension SPM.ManifestDumpError:TraceableError
{
    public
    var notes:[String]
    {
        ["while dumping manifest for package at '\(self.root)'"]
    }
}
