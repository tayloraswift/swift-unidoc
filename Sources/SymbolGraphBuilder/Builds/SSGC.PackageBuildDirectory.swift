import Symbols
import SystemIO

extension SSGC {
    /// An SPM build directory. It is usually, but not always, named `.build`.
    struct PackageBuildDirectory {
        let configuration: PackageBuildConfiguration
        let location: FilePath.Directory

        init(configuration: PackageBuildConfiguration, location: FilePath.Directory) {
            guard location.path.isAbsolute else {
                fatalError("""
                    Package build directory must be an absolute path,
                    for IndexStoreDB compatibility!
                    """)
            }

            self.configuration = configuration
            self.location = location
        }
    }
}
extension SSGC.PackageBuildDirectory {
    var index: FilePath.Directory {
        self.location / "\(self.configuration)" / "index"
    }

    var modules: FilePath.Directory {
        self.location / "\(self.configuration)" / "Modules"
    }

    func modulemap(target: String) -> FilePath {
        self.build(target: target) / "module.modulemap"
    }

    /// This takes an unmangled target name, not a c99 name.
    private func build(target: String) -> FilePath.Directory {
        self.location / "\(self.configuration)" / "\(target).build"
    }
}
