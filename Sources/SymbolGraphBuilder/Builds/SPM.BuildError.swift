extension SPM
{
    @frozen public
    enum BuildError:Error
    {
        case swift_package_update(Int32)
        case swift_build(Int32)
    }
}
