extension SPM
{
    @frozen public
    enum BuildError:Error
    {
        case swift_build(Int32)
    }
}
