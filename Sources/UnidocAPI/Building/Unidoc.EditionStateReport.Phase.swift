import JSON

extension Unidoc.EditionStateReport
{
    /// A description of the current state of the documentation for a package version.
    /// This is computed from the other fields in the ``EditionStateReport`` and is not stored
    /// directly in the database. Some clients, such as CI systems, may find these descriptions
    /// more understandable than the raw state.
    @frozen public
    enum Phase:String, Equatable, Sendable
    {
        /// The default state. The documentation is in this state initially, after a build has
        /// been cancelled without any actively-linked documentation already existing, or after
        /// documentation has been deleted. The documentation is also in this state during the
        /// very brief interval between when a build has completed successfully, and when it has
        /// been fully-linked.
        case DEFAULT
        /// The package has been queued for a documentation build.
        case QUEUED
        /// The package has been queued for a documentation build, but the version has not yet
        /// been selected. The version that will eventually be selected may still match the
        /// version the client is interested in.
        case QUEUED_FLOATING_VERSION
        /// The package has been queued for a documentation build, and it is definitively known
        /// that the version that will be selected is different from the version the client is
        /// interested in.
        case QUEUED_DIFFERENT_VERSION
        /// The previous build was skipped because the selected version had already been built.
        case SKIPPED
        /// The package is being assigned a builder and a version to build.
        case ASSIGNING

        /// A builder is cloning some version of the package.
        case ASSIGNED_CLONING_REPOSITORY
        /// A builder is compiling and generating documentation for some version of the package.
        case ASSIGNED_BUILDING

        /// The documentation is actively-linked and renderable.
        ///
        /// This is the only state where the documentation should be considered complete and
        /// ready to be displayed.
        ///
        /// >   Important:
        /// >   The documentation may be in this state even if the previous build has failed.
        /// >   The most common reason why is because the failed build was for a different
        /// >   version of the package.
        case ACTIVE

        /// The previous build failed during the cloning phase.
        case FAILED_CLONE_REPOSITORY
        /// The previous build failed while reading the manifest for the package or one of its
        /// dependencies.
        case FAILED_READ_MANIFEST
        /// The previous build failed during the dependency resolution phase.
        case FAILED_RESOLVE_DEPENDENCIES
        /// The previous build failed during the `swift build` phase.
        case FAILED_COMPILE_CODE
        /// The previous build failed during the `swift symbolgraph-extract` phase.
        case FAILED_EXTRACT_SYMBOLS
        /// The previous build failed during the documentation generation phase.
        case FAILED_COMPILE_DOCS
        /// The previous build failed for an unknown reason.
        case FAILED_UNKNOWN
    }
}
extension Unidoc.EditionStateReport.Phase:JSONEncodable, JSONDecodable
{
}
