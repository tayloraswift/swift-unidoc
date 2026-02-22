import SymbolGraphs
import Symbols
import SystemIO

extension SSGC {
    struct PackageRoot {
        let location: FilePath.Directory

        private init(normalized location: FilePath.Directory) {
            self.location = location
        }
    }
}
extension SSGC.PackageRoot {
    init(normalizing location: FilePath.Directory) {
        self.init(normalized: .init(path: location.path.lexicallyNormalized()))
    }

    init(normalizing root: Symbol.FileBase) {
        self.init(normalizing: FilePath.Directory.init(root.path))
    }
}
extension SSGC.PackageRoot {
    func rebase(_ path: FilePath) -> Symbol.File {
        guard path.components.starts(with: self.location.path.components) else {
            fatalError("Could not lexically rebase file path '\(path)'")
        }

        let relative: FilePath = .init(
            root: nil,
            path.components.dropFirst(self.location.path.components.count)
        )

        return .init("\(relative)")
    }
}
extension SSGC.PackageRoot {
    func layouts(
        modules: [SymbolGraph.Module],
        exclude: [[String]]
    ) throws -> [SSGC.ModuleLayout] {
        let count: [SSGC.ModuleLayout.DefaultDirectory: Int] = modules.reduce(
            into: [:]
        ) {
            if  case nil = $1.location,
                let directory: SSGC.ModuleLayout.DefaultDirectory = .init(for: $1.type) {
                $0[directory, default: 0] += 1
            }
        }

        var layouts: [SSGC.ModuleLayout] = []
        layouts.reserveCapacity(modules.count)

        for i: Int in modules.indices {
            layouts.append(
                try .init(
                    exclude: exclude[i],
                    package: self,
                    module: modules[i],
                    count: count
                )
            )
        }

        return layouts
    }

    func chapters() throws -> [SSGC.ModuleLayout] {
        var bundles: [(FilePath.Directory, FilePath.Component)] = []
        try location.walk {
            switch $1.extension {
            case "docc"?, "unidoc"?:
                bundles.append(($0, $1))
                return false

            default:
                return ($0 / $1).exists()
            }
        }

        return try bundles.map {
            try .init(
                package: self,
                bundle: $0 / $1,
                module: .init(name: $1.stem, type: .book)
            )
        }
    }

    func snippets(in snippetsDirectory: FilePath.Component) throws -> [SSGC.LazyFile] {
        let snippetsDirectory: FilePath.Directory = self.location / snippetsDirectory
        if !snippetsDirectory.exists() {
            return []
        }

        var snippets: [SSGC.LazyFile] = []
        try snippetsDirectory.walk {
            let file: (path: FilePath, extension: String)

            if  let `extension`: String = $1.extension {
                file.extension = `extension`
                file.path = $0 / $1
            } else {
                //  directory, or some extensionless file we don’t care about
                return true
            }

            if  file.extension == "swift" {
                //  Should we be mangling URL-unsafe characters?
                let snippet: SSGC.LazyFile = .init(
                    location: file.path,
                    path: self.rebase(file.path),
                    name: $1.stem
                )

                snippets.append(snippet)
                return true
            } else {
                return true
            }
        }

        return snippets
    }
}
