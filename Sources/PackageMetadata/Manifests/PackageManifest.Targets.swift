import Repositories

extension PackageManifest
{
    struct Targets:Sendable
    {
        private
        let index:[TargetIdentifier: Target]

        private
        init(index:[TargetIdentifier: Target])
        {
            self.index = index
        }
    }
}
extension PackageManifest.Targets
{
    init(indexing targets:[PackageManifest.Target]) throws
    {
        self.init(index: try .init(targets.lazy.map { ($0.id, $0) })
        {
            throw PackageManifest.TargetError.duplicate($1.id)
        })
    }

    func callAsFunction(_ id:TargetIdentifier) throws -> PackageManifest.Target
    {
        if  let target:PackageManifest.Target = self.index[id]
        {
            return target
        }
        else
        {
            throw PackageManifest.TargetError.undefined(id)
        }
    }
}
