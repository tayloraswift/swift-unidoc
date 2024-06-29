//  run with: /bin/mongosh --file /unidoc-rs-init-containerized.js
db = connect('mongodb://unidoc-mongod:27017/admin');
db.runCommand({'replSetInitiate': {
    "_id": "unidoc-rs",
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "unidoc-mongod:27017",
            "tags": {},
            "priority": 1
        }
    ]
}});
