import System
import Symbols

extension SSGC
{
    struct PackageRoot
    {
        let path:FilePath

        private
        init(normalized path:FilePath)
        {
            self.path = path
        }
    }
}
extension SSGC.PackageRoot
{
    init(normalizing path:FilePath)
    {
        self.init(normalized: path.lexicallyNormalized())
    }

    init(normalizing root:Symbol.FileBase)
    {
        self.init(normalizing: FilePath.init(root.path))
    }
}
extension SSGC.PackageRoot
{
    func rebase(_ path:FilePath) -> Symbol.File
    {
        guard path.components.starts(with: self.path.components)
        else
        {
            fatalError("Could not lexically rebase file path '\(path)'")
        }

        let relative:FilePath = .init(root: nil,
            path.components.dropFirst(self.path.components.count))

        return .init("\(relative)")
    }
}
