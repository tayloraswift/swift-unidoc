import HTML
import Media
import URI

extension Unidoc.VersionsPage
{
    struct BuildTools
    {
        let package:Unidoc.PackageMetadata
        let build:Unidoc.BuildMetadata?
        let view:Unidoc.Permissions
        let back:URI

        init(package:Unidoc.PackageMetadata,
            build:Unidoc.BuildMetadata?,
            view:Unidoc.Permissions,
            back:URI)
        {
            self.package = package
            self.build = build
            self.view = view
            self.back = back
        }
    }
}
extension Unidoc.VersionsPage.BuildTools:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        if  let progress:Unidoc.BuildProgress = self.build?.progress
        {
            section[.div]
            {
                $0.title = "You cannot cancel a build that has already started!"
            } = "Cancel build"

            switch progress.request
            {
            case .latest(let series, force: _):
                section[.div] = "Queued (\(series))"

            case .id:
                section[.div] = "Queued (ref)"
            }

            switch progress.stage
            {
            case .initializing:
                section[.div]
                {
                    $0.class = "phase"
                    $0.title = "The builder is initializing."
                } = "Started (git)"

            case .cloningRepository:
                section[.div]
                {
                    $0.class = "phase"
                    $0.title = "The builder is cloning the package’s repository."
                } = "Started (git)"

            case .resolvingDependencies:
                section[.div]
                {
                    $0.class = "phase"
                    $0.title = "The builder is resolving the package’s dependencies."
                } = "Started (swiftpm)"

            case .compilingCode:
                section[.div]
                {
                    $0.class = "phase"
                    $0.title = "The builder is compiling the package’s source code."
                } = "Started (swift)"
            }
        }
        else if
            let request:Unidoc.BuildRequest = self.build?.request
        {
            if  self.view.editor
            {
                section[.form]
                {
                    $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                    $0.action = "\(Unidoc.Post[.build, confirm: true])"
                    $0.method = "post"
                } = Unidoc.BuildButton.latest(of: self.package, cancel: true)
            }
            else
            {
                section[.form] = Unidoc.DisabledButton.init(
                    label: "Cancel build",
                    view: self.view)
            }

            switch request
            {
            case .latest(let series, force: _):
                section[.div]
                {
                    $0.class = "phase"
                    $0.title = "The builder will build the latest \(series) version."
                } = "Queued (\(series))"

            case .id:
                section[.div]
                {
                    $0.class = "phase"
                    $0.title = "The builder will build the specified git ref."
                } = "Queued (ref)"
            }

            section[.div]
        }
        else
        {
            if  self.view.editor
            {
                section[.form]
                {
                    $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                    $0.action = "\(Unidoc.Post[.build, confirm: true])"
                    $0.method = "post"
                } = Unidoc.BuildButton.latest(of: self.package)
            }
            else
            {
                section[.form] = Unidoc.DisabledButton.init(
                    label: "Request build",
                    view: self.view)
            }

            section[.div]

            switch self.build?.failure
            {
            case .timeout?:
                section[.div]
                {
                    $0.title = """
                    We failed to build the package in the allotted time.
                    """
                } = "Failed (timeout)"

            case .noValidVersion?:
                section[.div]
                {
                    $0.title = """
                    There were no valid versions of this package to build.
                    """
                } = "Skipped"

            case .failedToCloneRepository?:
                section[.div]
                {
                    $0.title = """
                    We failed to clone the package’s repository.
                    """
                } = "Failed (git)"

            case .failedToReadManifest?:
                section[.div]
                {
                    $0.title = """
                    We failed to detect the package’s manifest.
                    """
                } = "Failed (swiftpm)"

            case .failedToReadManifestForDependency?:
                section[.div]
                {
                    $0.title = """
                    We failed to read the manifest of one of the package’s dependencies.
                    """
                } = "Failed (swiftpm)"

            case .failedToResolveDependencies?:
                section[.div]
                {
                    $0.title = """
                    We failed to resolve the package’s dependencies.
                    """
                } = "Failed (swiftpm)"

            case .failedToBuild?:
                section[.div]
                {
                    $0.title = """
                    We failed to build the package’s source code.
                    """
                } = "Failed (swift)"

            case .failedToExtractSymbolGraph?:
                section[.div]
                {
                    $0.title = """
                    We failed to extract the package’s symbol graphs.
                    """
                } = "Failed (swift)"

            case .failedToLoadSymbolGraph?:
                section[.div]
                {
                    $0.title = """
                    We failed to parse the package’s symbol graphs.
                    """
                } = "Failed (ssgc)"

            case .failedToLinkSymbolGraph?:
                section[.div]
                {
                    $0.title = """
                    We failed to link the package’s documentation.
                    """
                } = "Failed (ssgc)"

            case .failedForUnknownReason?:
                section[.div]
                {
                    $0.title = """
                    The builder crashed for an unknown reason.
                    """
                } = "Failed (ssgc)"

            case nil:
                section[.div]
            }
        }
    }
}
