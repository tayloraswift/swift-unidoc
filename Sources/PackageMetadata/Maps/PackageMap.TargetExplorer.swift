import PackageGraphs

extension PackageMap
{
    /// Context for a breadth-first traversal of a target graph.
    struct TargetExplorer
    {
        private
        let targets:Targets

        /// Targets that have been fully explored. Once ``queued`` becomes
        /// empty again, this will contain every target of interest.
        private
        var visited:[String: PackageManifest.Target]
        /// Targets that have been discovered, but not explored through.
        private
        var queued:[PackageManifest.Target]

        init(targets:Targets)
        {
            self.targets = targets

            self.visited = [:]
            self.queued = []
        }
    }
}
extension PackageMap.TargetExplorer
{
    /// Enqueues the given target if it has not already been visited.
    mutating
    func explore(target:PackageManifest.Target)
    {
        {
            if  case nil = $0
            {
                self.queued.append(target)
                $0 = target
            }
        } (&self.visited[target.name])
    }

    /// Looks up and enqueues the given target if it has not already been visited.
    /// No lookup happens if the target has already been visited.
    mutating
    func explore(target name:String) throws
    {
        try
        {
            if  case nil = $0
            {
                let target:PackageManifest.Target = try self.targets(name)
                self.queued.append(target)
                $0 = target
            }
        } (&self.visited[name])
    }
    mutating
    func conquer(by advance:(inout Self, PackageManifest.Target) throws -> ())
        rethrows -> [String: PackageManifest.Target]
    {
        while let target:PackageManifest.Target = self.queued.popLast()
        {
            try advance(&self, target)
        }
        return self.visited
    }
}
