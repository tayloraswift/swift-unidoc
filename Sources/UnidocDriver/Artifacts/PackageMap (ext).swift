import PackageMetadata
import PackageGraphs
import System

extension PackageMap
{
    func scan() throws -> [Artifacts.Sources]
    {
        let root:FilePath = .init(self.root.path)
        return try self.targets.indices.map
        {
            (index:Int) in

            var sources:Artifacts.Sources = .init(self.targets[index], root: root)
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
