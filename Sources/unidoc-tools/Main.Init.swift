import ArgumentParser
import System

extension Main
{
    struct Init
    {
        @Argument
        var location:FilePath.Directory

        @Option(
            name: [.customLong("container"), .customShort("c")],
            help: "Container name")
        var container:String = "unidoc-mongod-container"

        @Flag(
            name: [.customLong("containerized"), .customShort("m")],
            help: """
            Use containerized setup - this prevents documentation preview servers from running \
            on the host, but allows preview servers to run from inside other Docker containers
            """)
        var containerized:Bool = false
    }
}
extension Main.Init:AsyncParsableCommand
{
    public
    static let configuration:CommandConfiguration = .init(commandName: "init")

    func run() async throws
    {
        try self.location.create()

        let installation:Installation = .init(
            docker_compose_yml: self.location / "docker-compose.yml",
            unidoc_rs_init_js: self.location / "unidoc-rs-init.js",
            unidoc_rs_conf: self.location / "unidoc-rs.conf",
            container: self.container,
            localhost: !self.containerized)

        try installation.create()

        try SystemProcess.init(command: "docker",
            "compose",
            "--file", "\(installation.docker_compose_yml)",
            "up",
            "--detach",
            "--wait",
            echo: true)()

        //  Even though the container is ready, the `mongod` daemon within it may not be.
        //  We need to wait for it to be ready before we can run the `mongosh` command.
        //  We do this by pinging the `mongod` daemon until it responds.
        print("Waiting for mongod to start up...")

        var attempts:Int = 0
        waiting: do
        {
            async
            let interval:Void = Task.sleep(for: .seconds(1))
            do
            {
                try SystemProcess.init(command: "docker",
                    "exec",
                    "\(installation.container)",
                    "mongosh",
                    "--quiet",
                    "--eval", "exit")()
            }
            catch let error
            {
                if  attempts > 10
                {
                    throw error
                }
                else
                {
                    attempts += 1
                }

                try await interval
                continue waiting
            }
        }

        print("Initializing replica set...")

        try SystemProcess.init(command: "docker",
            "exec",
            "--tty",
            "\(installation.container)",
            "/bin/mongosh", "--file", "/unidoc-rs-init.js",
            echo: true)()

        print("Successfully initialized MongoDB replica set!")
        print("    Docker compose file: \(installation.docker_compose_yml)")
        print("    Docker container: \(installation.container)")
    }
}
