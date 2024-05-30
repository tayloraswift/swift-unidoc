import System
import Symbols

extension SSGC
{
    struct PackageRoot
    {
        let location:FilePath.Directory

        private
        init(normalized location:FilePath.Directory)
        {
            self.location = location
        }
    }
}
extension SSGC.PackageRoot
{
    init(normalizing location:FilePath.Directory)
    {
        self.init(normalized: .init(path: location.path.lexicallyNormalized()))
    }

    init(normalizing root:Symbol.FileBase)
    {
        self.init(normalizing: FilePath.Directory.init(root.path))
    }
}
extension SSGC.PackageRoot
{
    func rebase(_ path:FilePath) -> Symbol.File
    {
        guard path.components.starts(with: self.location.path.components)
        else
        {
            fatalError("Could not lexically rebase file path '\(path)'")
        }

        let relative:FilePath = .init(root: nil,
            path.components.dropFirst(self.location.path.components.count))

        return .init("\(relative)")
    }
}
