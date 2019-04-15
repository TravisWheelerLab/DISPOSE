$(document).ready(function() {

    //Get hash from URL. Ex. index.html#Chapter1
    var hash = location.hash;

    if (hash == '#sub') {
       openTab(event, 'submission');
    }
    else if (hash == '#res') {
    	openTab(event, 'results');
    }
    else if (hash == '#waste') {
    	openTab(event, 'waste');
    }
})