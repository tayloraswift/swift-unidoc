@frozen public
struct ToolchainBuild
{
    /// Where to emit documentation artifacts to.
    let output:Workspace

    private
    init(output:Workspace)
    {
        self.output = output
    }
}
extension ToolchainBuild
{
    public static
    func swift(in shared:Workspace, clean:Bool = false) async throws -> Self
    {
        self.init(output: try await shared.create("swift", clean: clean).create("artifacts"))
    }
}
