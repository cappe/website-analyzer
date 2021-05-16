/**
 * This was a backup plan if the lighthouse-batch-parallel CLI didn't work.
 */

const fs = require('fs');
const {lighthouseBatchParallel} = require('lighthouse-batch-parallel');

const args = process
    .argv
    .slice(2)
    .reduce((acc, keyVal) => {
        const [key, val] = keyVal.split('=');
        acc[key] = val;
        return acc;
    }, {})
const {
    sitemap,
    output,
    destDir,
    workers = 1,
} = args;

console.log('Running lighthouse-parallel-runner with the following input:');
console.log('sitemap:', sitemap);
console.log('output:', output);
console.log('destDir:', destDir);
console.log('workers:', workers);

const customAuditsConfig = {
    'cumulative-layout-shift': 'Cumulative Layout Shift',
};

const lighthouseAuditing = lighthouseBatchParallel({
    input: sitemap,
    customAudits: {stream: customAuditsConfig},
    outputFormat: 'jsObject',
    workersNum: workers,
});

lighthouseAuditing.on('data', ({data, progress}) => {
    console.log('progress', progress);
    fs.writeFile(`${destDir}/${output}`, JSON.stringify(data, null, 2), {flag: 'a'}, err => {
    })
});

// lighthouseAuditing.on('error', ({ error }) => {
//     console.log('error', error);
// });
//
// lighthouseAuditing.on('end', () => {
//     console.log('reports', reports);
// });
