import HTML
import SemanticVersions

extension Unidoc
{
    struct DependencyTable
    {
        let dependencies:[VolumeMetadata.Dependency]
        let context:RelativePageContext

        init(dependencies:[VolumeMetadata.Dependency], context:RelativePageContext)
        {
            self.dependencies = dependencies
            self.context = context
        }
    }
}
extension Unidoc.DependencyTable:HTML.OutputStreamable
{
    static
    func += (table:inout HTML.ContentEncoder, self:Self)
    {
        table[.thead]
        {
            $0[.tr]
            {
                $0[.th] = "Package"
                $0[.th] = "Requirement"
                $0[.th] = "Resolved Version"
            }
        }
        table[.tbody]
        {
            for dependency:Unidoc.VolumeMetadata.Dependency in self.dependencies
            {
                $0[.tr]
                {
                    let pinned:Unidoc.VolumeMetadata?

                    if  let volume:Unidoc.Edition = dependency.pin?.linked,
                        let volume:Unidoc.VolumeMetadata = self.context[volume]
                    {
                        //  We link to the tags page here, because we are already
                        //  linking to the specific version in the other column.
                        pinned = volume
                        $0[.td]
                        {
                            $0[.a]
                            {
                                $0.href = "\(Unidoc.TagsEndpoint[volume.symbol.package])"
                            } = "\(volume.symbol.package)"
                        }
                    }
                    /*
                    else if case _? = dependency.pin
                    {
                        //  We were able to pin the dependency to a known edition,
                        //  but we don't have any documentation for it.
                        //  The volume’s exonym for that package is likely a valid
                        //  way to access the page for that package, so we will
                        //  generate a link to that. We know this because the only
                        //  way the dependency could have been pinned in the first
                        //  place is if the exonym was a valid alias for the package
                        //  at some point in the past.
                        //
                        //  This isn’t 100% safe, because the exonym may have been
                        //  deregistered or usurped by another package. But it is
                        //  useful enough to be worth the 404 errors.
                        pinned = nil
                        $0[.td]
                        {
                            $0[.a]
                            {
                                $0.href = "\(Unidoc.TagsEndpoint[dependency.exonym])"
                            } = "\(dependency.exonym)"
                        }
                    }
                    */
                    else
                    {
                        pinned = nil
                        $0[.td] = "\(dependency.exonym)"
                    }

                    switch dependency.requirement
                    {
                    case nil:                   $0[.td]
                    case .exact(let version)?:  $0[.td] = "\(version)"
                    case .range(let lower, to: let upper)?:    $0[.td]
                        {
                            $0 += "\(lower)"
                            $0[.span] { $0.class = "upto" } = "..<"
                            $0 += "\(upper)"
                        }
                    }

                    if  let pinned:Unidoc.VolumeMetadata
                    {
                        $0[.td]
                        {
                            $0[.a]
                            {
                                $0.href = "\(Unidoc.DocsEndpoint[pinned])"
                            } = pinned.symbol.version
                        }
                    }
                    else if
                        let version:PatchVersion = dependency.resolution
                    {
                        $0[.td] = "\(version)"
                    }
                    else
                    {
                        $0[.td] { $0.class = "placeholder" } = "unstable"
                    }
                }
            }
        }
    }
}
