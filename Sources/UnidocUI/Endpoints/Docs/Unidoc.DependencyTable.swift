import HTML
import SemanticVersions
import Symbols

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
                $0[.th] = "Resolved version"
            }
        }
        table[.tbody]
        {
            for dependency:Unidoc.VolumeMetadata.Dependency in self.dependencies
            {
                $0[.tr]
                {
                    let tags:Symbol.Package?
                    //  We need to check for the standard library first, as we will not usually
                    //  have the package metadata for it. The standard library is also special,
                    //  so we always know its name.
                    if  dependency.exonym == .swift
                    {
                        tags = .swift
                    }
                    else if
                        let pinned:Unidoc.VolumeMetadata.DependencyPin = dependency.pin
                    {
                        tags = self.context[package: pinned.edition.package]?.symbol
                        //  This needs to be here temporarily, until we have re-uplinked all the
                        //  landing page vertices.
                            ?? self.context[pinned.edition]?.symbol.package
                    }
                    else
                    {
                        tags = nil
                    }

                    if  let tags:Symbol.Package
                    {
                        //  We link to the tags page here, because we are already
                        //  linking to the specific version in the other column.
                        $0[.td]
                        {
                            $0[.a]
                            {
                                $0.href = "\(Unidoc.TagsEndpoint[tags])"
                            } = "\(dependency.exonym)"
                        }
                    }
                    else
                    {
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

                    if  let linked:Unidoc.Edition = dependency.pin?.linked,
                        let linked:Unidoc.VolumeMetadata = self.context[linked]
                    {
                        $0[.td]
                        {
                            $0[.a]
                            {
                                $0.href = "\(Unidoc.DocsEndpoint[linked])"
                            } = linked.symbol.version
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
