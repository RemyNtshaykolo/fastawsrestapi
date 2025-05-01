const path = require("path");
const webpack = require("webpack");
const HtmlWebpackPlugin = require("html-webpack-plugin");
// const { CleanWebpackPlugin } = require('clean-webpack-plugin');
// const CopyWebpackPlugin = require('copy-webpack-plugin');

const outputPath = path.resolve(__dirname, "doc_build");

module.exports = (env) => {
  return {
    mode: "production",
    entry: {
      app: require.resolve("./src/api/doc/index"),
    },
    resolve: {
      extensions: [".ts", ".js"],
    },
    module: {
      rules: [
        {
          test: /\.css$/,
          use: [{ loader: "style-loader" }, { loader: "css-loader" }],
        },
      ],
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: "src/api/doc/index.html",
      }),
      new webpack.DefinePlugin({
        API_TITLE: `"${process.env.API_TITLE}"`,
      }),
    ],
    output: {
      filename: "[name].bundle.js",
      path: outputPath,
    },
  };
};
