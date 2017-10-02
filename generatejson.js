const { writeFile, lstatSync, readdirSync, readFileSync } = require('fs')
const { join, extname } = require('path')

const dataPath = "./data"
const distPath = "./src/articles.json"

function isDirectory(source) {
    return lstatSync(source).isDirectory();
}

function getFileContents(path) {
    return readFileSync(path).toString();
}

function getDirectories(source) {
    return readdirSync(source)
        .map(name => join(source, name))
        .filter(isDirectory);
}

function getFileTypeContent(arr, extension) {
    const file = arr.filter(file => extname(file) === extension).pop();

    return getFileContents(file);
}

function buildJson() {
    const files = getDirectories(dataPath)
        .map(source => readdirSync(source)
            .map(x => join(source, x)));

    const json = files.map(folder => {
        const json = JSON.parse(getFileTypeContent(folder, ".json"));
        const js = getFileTypeContent(folder, ".js");
        const elm = getFileTypeContent(folder, ".elm");

        return Object.assign({ elm: elm, js: js }, json);
    })

    saveJson(json)
}

function saveJson(data) {
    writeFile(distPath, JSON.stringify(data), function (err) {
        if (err) {
            console.log(err);
        } else {
            console.log("Saved");
        }
    });
}

buildJson();
