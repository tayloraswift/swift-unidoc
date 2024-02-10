import System
import Symbols

extension SPM
{
    struct PathSymbolizer
    {
        private
        let root:FilePath

        private
        init(normalized root:FilePath)
        {
            self.root = root
        }
    }
}
extension SPM.PathSymbolizer
{
    init(root:Symbol.FileBase)
    {
        self.init(normalized: FilePath.init(root.path).lexicallyNormalized())
    }
}
extension SPM.PathSymbolizer
{
    func rebase(_ path:FilePath) -> Symbol.File
    {
        guard path.components.starts(with: root.components)
        else
        {
            fatalError("Could not lexically rebase file path '\(path)'")
        }

        let relative:FilePath = .init(root: nil,
            path.components.dropFirst(root.components.count))

        return .init("\(relative)")
    }
}
