// recap.js

// zero out Bootstrap's scrollbar-width measurement so it adds no padding-right on open
$('#recapModal')
	.on('show.bs.modal', function() { document.documentElement.style.overflowY = 'scroll'; })
	.on('hidden.bs.modal', function() { document.documentElement.style.removeProperty('overflow-y'); });

const recapMessageText = $('#recapText').text()

// Split the paragraph into sentences
const sentences = recapMessageText.split(/(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?)\s/);

// Group sentences into paragraphs every two sentences
const paragraphs = [];
for (let i = 0; i < sentences.length; i += 2) {
    paragraphs.push(sentences.slice(i, i + 2).join(' '));
}

// Output paragraphs
$('#recapText').html('<p>' + paragraphs.join('</p><p>') + '</p>');