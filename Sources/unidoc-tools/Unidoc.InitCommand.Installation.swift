import System_

extension Unidoc.InitCommand
{
    struct Installation
    {
        let docker_compose_yml:FilePath
        let unidoc_rs_init_js:FilePath
        let unidoc_rs_conf:FilePath

        let container:String
        let localhost:Bool
    }
}
extension Unidoc.InitCommand.Installation
{
    func create() throws
    {
        for (file, content):(FilePath, String) in [
            (
                self.docker_compose_yml,
                Self.docker_compose_yml(container: self.container)
            ),
            (
                self.unidoc_rs_conf,
                Self.unidoc_rs_conf
            ),
            (
                self.unidoc_rs_init_js,
                Self.unidoc_rs_init_js(host: self.localhost ? "localhost" : "unidoc-mongod")
            )
        ]
        {
            try file.open(.writeOnly, permissions: (.rw, .r, .r), options: [.create, .truncate])
            {
                _ = try $0.writeAll(content.utf8)
            }
        }
    }
}

extension Unidoc.InitCommand.Installation
{
    private
    static func docker_compose_yml(container:String) -> String
    {
        """
        services:
            unidoc-mongod:
                image: mongo:latest
                container_name: \(container)
                hostname: unidoc-mongod
                networks:
                    - unidoc-test
                ports:
                    - 27017:27017
                restart: always
                volumes:
                    # cannot put this in docker-entrypoint-initdb.d, it does not work
                    - ./unidoc-rs-init.js:/unidoc-rs-init.js
                    - ./unidoc-rs.conf:/etc/mongod.conf
                    - ./mongod:/data/db
                command: mongod --config /etc/mongod.conf


        networks:
            unidoc-test:
                name: unidoc-test
                enable_ipv6: true
                ipam:
                    config:
                        - subnet: 2001:0DB8::/112

        """
    }

    private
    static let unidoc_rs_conf:String = """
    replication:
        replSetName: unidoc-rs
    net:
        port: 27017
        bindIp: 0.0.0.0
        bindIpAll: true

    """

    private
    static func unidoc_rs_init_js(host:String) -> String
    {
        """
        db = connect('mongodb://unidoc-mongod:27017/admin');
        db.runCommand({'replSetInitiate': {
            "_id": "unidoc-rs",
            "version": 1,
            "members": [
                {
                    "_id": 0,
                    "host": "\(host):27017",
                    "tags": {},
                    "priority": 1
                }
            ]
        }});

        """
    }
}
