import Unidoc
import UnidocRecords

extension Volume
{
    struct Types
    {
        private(set)
        var cultures:[Unidoc.Scalar: [Unidoc.Scalar: Node]]
        private(set)
        var combined:[Unidoc.Scalar: Node]

        init()
        {
            self.cultures = [:]
            self.combined = [:]
        }
    }
}
extension Volume.Types
{
    subscript(culture:Unidoc.Scalar, id:Unidoc.Scalar) -> Node?
    {
        get
        {
            self.combined[id]
        }
        set (value)
        {
            self.cultures[culture, default: [:]][id] = value
            self.combined[id] = value
        }
    }

    func trees() -> [Volume.NounTree]
    {
        self.cultures.map
        {
            var aliens:Set<Unidoc.Scalar> = []
            var rows:[Volume.Noun] = []
                rows.reserveCapacity($0.value.count)

            for type:Node in $0.value.values
            {
                rows.append(.init(shoot: type.shoot, same: .culture))

                var scope:Unidoc.Scalar? = type.scope
                var stem:Volume.Stem = type.shoot.stem
                //  Prevent infinite loops.
                for _:Int in 1 ..< max(1, stem.depth)
                {
                    guard let type:Unidoc.Scalar = scope
                    else
                    {
                        break
                    }
                    // Don’t synthesize nodes more than once.
                    guard !$0.value.keys.contains(type), case nil = aliens.update(with: type)
                    else
                    {
                        break
                    }

                    if  let type:Node = self.combined[type]
                    {
                        rows.append(.init(shoot: type.shoot, same: .package))
                        scope = type.scope
                        stem = type.shoot.stem
                    }
                    else if
                        let scope:[Substring] = stem.split()?.scope
                    {
                        for scope:Substring in scope
                        {
                            let slice:Volume.Stem = .init(
                                rawValue: String.init(stem.rawValue[..<scope.endIndex]))

                            rows.append(.init(shoot: .init(stem: slice, hash: nil)))
                        }

                        break
                    }
                    else
                    {
                        break
                    }
                }
            }

            return .init(id: $0.key, rows: rows.sorted { $0.shoot < $1.shoot })
        }
    }
}
