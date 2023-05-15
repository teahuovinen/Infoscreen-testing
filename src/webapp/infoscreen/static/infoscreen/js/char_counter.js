$(document).ready(function() {
    // get the release_body element
    var releaseBody = $('textarea[name="release_body"]');
    var releaseTitle = $('textarea[name="release_title"]');

    // create a div to show the remaining characters count
    var charCounterBody = $('<div id="charcounterbody" class="char-counter"></div>').insertAfter(releaseBody);
    var charCounterTitle = $('<div id="charcountertitle" class="char-counter"></div>').insertAfter(releaseTitle);

    // calculate and display the remaining characters count
    function updateCharCountBody() {
        var remainingCharsBody = 700 - releaseBody.val().length;
        charCounterBody.text('Remaining characters: ' + remainingCharsBody);
    }

    function updateCharCountTitle() {
        var remainingCharsTitle = 100 - releaseTitle.val().length;
        charCounterTitle.text('Remaining characters: ' + remainingCharsTitle);
    }

    // call the updateCharCount function when the release_body changes
    releaseBody.on('input', updateCharCountBody);
    releaseTitle.on('input', updateCharCountTitle);

    // update the counter on page load
    updateCharCountBody();
    updateCharCountTitle();
});