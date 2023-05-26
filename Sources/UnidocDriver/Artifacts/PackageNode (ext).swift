import ModuleGraphs
import PackageGraphs
import SymbolGraphs
import System

extension PackageNode
{
    func pinnedDependencies(
        using pins:[Repository.Pin]) throws -> [DocumentationMetadata.Dependency]
    {
        let pins:Repository.Pins = try .init(indexing: pins)
        return try self.dependencies.map
        {
            let pin:Repository.Pin = try pins($0.id)
            return .init(package: $0.id,
                requirement: $0.requirement?.stable,
                revision: pin.revision,
                ref: pin.ref)
        }
    }
    func scan() throws -> [Artifacts.Sources]
    {
        let root:FilePath = .init(self.root.path)
        return try self.modules.indices.map
        {
            (index:Int) in

            var sources:Artifacts.Sources = .init(self.modules[index], root: root)
            if  let path:FilePath = sources.path
            {
                let exclude:Set<FilePath> = .init(self.exclude[index].lazy.map { path / $0 })
                try sources.path?.directory.walk
                {
                    switch (sources.language, $0.extension)
                    {
                    case    (_, "md"?):
                        sources.articles.append($0)

                    case    (.swift, "h"?),
                            (.swift, "c"?):

                        if !exclude.contains($0)
                        {
                            sources.language = .c
                        }

                    case    (_, "hpp"?),
                            (_, "hxx"?),
                            (_, "cpp"?),
                            (_, "cxx"?):

                        if !exclude.contains($0)
                        {
                            sources.language = .cpp
                        }

                    case _:
                        break
                    }
                }
            }

            return sources
        }
    }
}
