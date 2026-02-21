extension Unidoc.RefsTable.Row.Graph {
    enum State {
        case some(Unidoc.VersionState.Graph)
        case none(Unidoc.Edition)
    }
}
