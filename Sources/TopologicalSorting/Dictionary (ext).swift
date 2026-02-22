extension Dictionary where Key: Comparable, Value: Identifiable<Key> {
    /// Performs a topological sort over the values of this dictionary using the provided edge
    /// list. Each edge represents a constraint where the value associated with the first tuple
    /// element must precede the value associated with the second tuple element.
    ///
    /// The key type must be ``Comparable`` in order to ensure a deterministic sort order. It is
    /// assumed that each key of the dictionary satisfies `self[k].id == k`.
    ///
    /// Edges that reference non-existent keys are ignored.
    @inlinable public func orderingValuesTopologically(
        by edges: some Sequence<(Key, Key)>
    ) -> [Value]? {
        let dependencies: [Key: Set<Key>]
        var dependents: [Key: [Value]]

        (dependencies, dependents) = edges.reduce(into: ([:], [:])) {
            if  let dependent: Value = self[$1.1], self.keys.contains($1.0) {
                $0.0[$1.1, default: []].insert($1.0)
                $0.1[$1.0, default: []].append(dependent)
            }
        }

        var sources: [Value] = self.values.filter { !dependencies.keys.contains($0.id) }

        //  Note: Polarities reversed, because the actual sorting algorithm pops from the end.
        sources.sort { $1.id < $0.id }

        for i: Dictionary<Key, [Value]>.Index in dependents.indices {
            dependents.values[i].sort { $1.id < $0.id }
        }

        return self.orderingValuesTopologically(
            from: sources,
            dependencies: dependencies,
            dependents: dependents
        )
    }

    @inlinable func orderingValuesTopologically(
        from sources: consuming [Value],
        dependencies: consuming [Key: Set<Key>],
        dependents: consuming [Key: [Value]]
    ) -> [Value]? {
        var ordered: [Value] = [] ; ordered.reserveCapacity(self.count)

        while let source: Value = sources.popLast() {
            ordered.append(source)

            guard let next: [Value] = dependents.removeValue(forKey: source.id) else {
                continue
            }
            for next: Value in next {
                {
                    if  case _? = $0?.remove(source.id),
                        case true? = $0?.isEmpty {
                        sources.append(next)
                        $0 = nil
                    }
                } (&dependencies[next.id])
            }
        }

        //  Nodes may depend on packages we did not clone. This is completely
        //  normal and expected when packages have things like SPM plugins that
        //  don’t get built by default.
        for id: Key in dependents.keys where self.keys.contains(id) {
            return nil
        }

        return dependencies.isEmpty ? ordered : nil
    }
}
