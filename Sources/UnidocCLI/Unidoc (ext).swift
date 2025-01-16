import _GitVersion

extension Unidoc
{
    public
    static var version:String
    {
        .init(cString: _GitVersion.swiftpm_git_version())
    }
}
