import HTML

extension Unidoc.RefsPage {
    enum Heading {
        case repo
        case tags
        case branches
        case consumers
        case settings
        case settingsAdmin
        case builds
        case builtRecently
        case buildConfiguration
        case importRefs
    }
}
extension Unidoc.RefsPage.Heading: Identifiable {
    var id: String {
        switch self {
        case .repo:                 "ss:repo"
        case .tags:                 "ss:tags"
        case .branches:             "ss:branches"
        case .consumers:            "ss:consumers"
        case .settings:             "ss:settings"
        case .settingsAdmin:        "ss:settings-admin"
        case .builds:               "ss:builds"
        case .builtRecently:        "ss:built-recently"
        case .buildConfiguration:   "ss:build-configuration"
        case .importRefs:           "ss:import-refs"
        }
    }
}
extension Unidoc.RefsPage.Heading: HTML.OutputStreamableHeading {
    var display: String {
        switch self {
        case .repo:                 "Package repository"
        case .tags:                 "Package tags"
        case .branches:             "Package branches"
        case .consumers:            "Consumers"
        case .settings:             "Settings"
        case .settingsAdmin:        "Admin actions"
        case .builds:               "Builds"
        case .builtRecently:        "Built recently"
        case .buildConfiguration:   "Build configuration"
        case .importRefs:           "Add branches"
        }
    }
}
