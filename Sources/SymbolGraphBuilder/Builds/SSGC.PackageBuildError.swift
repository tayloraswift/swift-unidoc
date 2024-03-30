extension SSGC
{
    @frozen public
    enum PackageBuildError:Error
    {
        case swift_package_update(Int32)
        case swift_build(Int32)
    }
}
