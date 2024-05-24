import JSON
import Symbols

extension Unidoc
{
    @frozen public
    struct EditionStateReport:Sendable
    {
        public
        let id:Edition
        public
        let volume:Symbol.Edition?
        public
        let build:BuildStatus?

        init(id:Edition, volume:Symbol.Edition?, build:BuildStatus?)
        {
            self.id = id
            self.volume = volume
            self.build = build
        }
    }
}
extension Unidoc.EditionStateReport
{
    var phase:Phase
    {
        if  case _? = self.volume
        {
            return .ACTIVE
        }
        guard
        let build:Unidoc.BuildStatus = self.build
        else
        {
            return .DEFAULT
        }

        if  let failure:Unidoc.BuildFailure = build.failure
        {
            switch failure
            {
            case .noValidVersion:                       return .SKIPPED
            case .failedToCloneRepository:              return .FAILED_CLONE_REPOSITORY
            case .failedToReadManifest:                 return .FAILED_READ_MANIFEST
            case .failedToReadManifestForDependency:    return .FAILED_READ_MANIFEST
            case .failedToResolveDependencies:          return .FAILED_RESOLVE_DEPENDENCIES
            case .failedToBuild:                        return .FAILED_COMPILE_CODE
            case .failedToExtractSymbolGraph:           return .FAILED_EXTRACT_SYMBOLS
            case .failedToLoadSymbolGraph:              return .FAILED_COMPILE_DOCS
            case .failedToLinkSymbolGraph:              return .FAILED_COMPILE_DOCS
            case .failedForUnknownReason:               return .FAILED_UNKNOWN
            case .timeout:                              return .FAILED_UNKNOWN
            }
        }
        else if
            let stage:Unidoc.BuildStage = build.stage
        {
            switch stage
            {
            case .initializing:                         return .ASSIGNING
            case .cloningRepository:                    return .ASSIGNED_CLONING_REPOSITORY
            case .resolvingDependencies:                return .ASSIGNED_BUILDING
            case .compilingCode:                        return .ASSIGNED_BUILDING
            }
        }
        else
        {
            switch build.request
            {
            case .latest?:
                return .QUEUED_FLOATING_VERSION

            case .id(self.id, force: _)?:
                return .QUEUED

            case .id?:
                return .QUEUED_DIFFERENT_VERSION

            case .none:
                return .DEFAULT
            }
        }
    }
}
extension Unidoc.EditionStateReport
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id
        case volume
        case build
        case phase
    }
}
extension Unidoc.EditionStateReport:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.id] = self.id.version
        json[.volume] = self.volume
        json[.build] = self.build
        json[.phase] = self.phase
    }
}
