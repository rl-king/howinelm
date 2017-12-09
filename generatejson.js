const { writeFile, lstatSync, readdirSync, readFileSync } = require('fs');
const { join, extname, dirname } = require('path');

const dataPath = "./data";
const distPath = "./src/articles.json";

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

    if (file) {
        return getFileContents(file);
    } else {
        const note = `Error\n\nI wasn't able to find a file with the ${extension} extension in ${dirname(arr[0])}. \n\nI'm looking for a .js .elm .json and .md file in every folder. \nPlease add a ${extension} and file and try again : )\n`;
        console.log(note);

        process.exit();
    }
}

function buildJson() {
    const files = getDirectories(dataPath)
        .map(source => readdirSync(source)
            .map(x => join(source, x)));

    const json = files.map(folder => {
        const json = JSON.parse(getFileTypeContent(folder, ".json"));
        const js = getFileTypeContent(folder, ".js");
        const elm = getFileTypeContent(folder, ".elm");
        const readme = getFileTypeContent(folder, ".md");

        return Object.assign({ elm: elm, js: js, readme: readme }, json);
    });

    saveJson(json);
}

function saveJson(data) {
    writeFile(distPath, JSON.stringify(data), (err) => {
        if (err) {
            console.log(err);
        } else {
            console.log("Saved");
        }
    });
}

buildJson();
