const path = require("path");

module.exports = {
    entry: './Sources/Search.ts',
    output: {
        path: path.resolve(__dirname, '../Assets/js'),
        filename: 'Main.js',
    },
    devtool: "source-map",
    resolve: {
        extensions: ['.ts'],
    },
    module: {
        rules: [
            {
                use: 'ts-loader',
                test: /\.tsx?$/,
                exclude: /node_modules/,
            },
        ],
    },
};
