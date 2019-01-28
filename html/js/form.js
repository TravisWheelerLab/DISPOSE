function escapeHtml(unsafe) {
    return unsafe
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
 }

// $(document).ready(function(){
// 	$('#sourceFile1').bind('change', function() {
// 		var fileName = $(this).val();
// 		fileName = fileName.match(/[^\\/]+$/)[0];

// 		var longName = fileName;

// 		if (fileName.length >= 20)
// 			fileName = fileName.substring(0, 13) + "...";

// 		var shortName = fileName;

// 		$('#sourceLabel1').html("Source 1 File: <br>" + fileName);
// 		$('#sourceLabel1').attr('class', 'fileLabel custom-but accepted');

// 		var reader = new FileReader();

// 	    reader.onload = function(){
// 	      	var result = escapeHtml(reader.result);
// 	      	var lines = result.split("\n");
// 	      	lines = lines.map(str => str.replace(/\r$/, ""));

// 	      	var count = 1;
// 	      	var output = '';

// 	      	for (var i=0; i < lines.length; i++) {
// 	      		output = output + "<span class='line' ";
// 	      		output = output + "meta='" + count + "' id='line1_" + count + "'>";
// 	      		output = output + lines[i];
// 	      		output = output + "</span>\n";
// 	      		count = count + 1;
// 	      	}

// 	     	$('#code1').html(output);
// 	     	$('#code1').removeClass();

// 	     	hljs.initHighlighting.called = false;
// 			hljs.initHighlighting();

// 			$('#shortName1b').html(shortName + '\n' + "<span id='longName1b'></span>");
// 			$('#longName1b').html(longName);
// 	    };

// 	    reader.readAsText(this.files[0]);

// 	});

// 	$('#sourceFile2').bind('change', function() {
// 		var fileName = $(this).val();
// 		fileName = fileName.match(/[^\\/]+$/)[0];

// 		var longName = fileName;

// 		if (fileName.length >= 20)
// 			fileName = fileName.substring(0, 13) + "...";

// 		var shortName = fileName;

// 		$('#sourceLabel2').html("Source 2 File: <br>" + fileName);
// 		$('#sourceLabel2').attr('class', 'fileLabel custom-but accepted');

// 		var reader = new FileReader();

// 	    reader.onload = function(){
// 	      	var result = escapeHtml(reader.result);
// 	      	var lines = result.split("\n");
// 	      	lines = lines.map(str => str.replace(/\r$/,""));

// 	      	var count = 1;
// 	      	var output = "";

// 	      	for (var i=0; i < lines.length; i++) {
// 	      		output = output + "<span class='line' ";
// 	      		output = output + "meta='" + count + "' id='line2_" + count + "'>";
// 	      		output = output + lines[i];
// 	      		output = output + "</span>\n";
// 	      		count = count + 1;
// 	      	}

// 	     	$('#code2').html(output);
// 	     	$('#code2').removeClass();
	     	
// 	     	hljs.initHighlighting.called = false;
// 			hljs.initHighlighting();


// 			$('#shortName2b').html(shortName + '\n' + "<span id='longName2b'></span>");
// 			$('#longName2b').html(longName);
// 	    };

// 	    reader.readAsText(this.files[0]);
// 	});

// 	// Tree form

// 	$('#treeFile1').bind('change', function() {
// 		var fileName = $(this).val();
// 		fileName = fileName.match(/[^\\/]+$/)[0];

// 		if (fileName.length >= 20)
// 			fileName = fileName.substring(0, 13) + "...";

// 		$('#treeLabel1').html("Tree 1 File: <br>" + fileName);
// 		$('#treeLabel1').attr('class', 'fileLabel custom-but accepted');
// 	});

// 	$('#treeFile2').bind('change', function() {
// 		var fileName = $(this).val();
// 		fileName = fileName.match(/[^\\/]+$/)[0];

// 		if (fileName.length >= 20)
// 			fileName = fileName.substring(0, 13) + "...";

// 		$('#treeLabel2').html("Tree 2 File: <br>" + fileName);
// 		$('#treeLabel2').attr('class', 'fileLabel custom-but accepted');
// 	});

// 	$('#pathsFile').bind('change', function() {
// 		var fileName = $(this).val();
// 		fileName = fileName.match(/[^\\/]+$/)[0];

// 		if (fileName.length >= 20)
// 			fileName = fileName.substring(0, 13) + "...";

// 		$('#pathsLabel').html("Paths File: <br>" + fileName);
// 		$('#pathsLabel').attr('class', 'fileLabel custom-but accepted');
// 	});
// 	$('#scoresFile').bind('change', function() {
// 		var fileName = $(this).val();
// 		fileName = fileName.match(/[^\\/]+$/)[0];

// 		if (fileName.length >= 20)
// 			fileName = fileName.substring(0, 13) + "...";

// 		$('#scoresLabel').html("Scores File: <br>" + fileName);
// 		$('#scoresLabel').attr('class', 'fileLabel custom-but accepted');
// 	});

// 	var $fileLabels = $('.fileLabel');
// 	var $sourceLabel1 = $('#sourceLabel1');
// 	var $sourceLabel2 = $('#sourceLabel2');

// 	var $treeLabel1 = $('#treeLabel1');
// 	var $treeLabel2 = $('#treeLabel2');
// 	var $pathsLabel = $('#pathsLabel');
// 	var $scoresLabel = $('#scoresLabel');


// 	$fileLabels.on('drop dragover dragenter', function(evt) {
// 		evt.preventDefault();
// 	});

// 	$sourceLabel1.on('dragenter dragover', function(evt) {
// 		$sourceLabel1.addClass('onLabel');
// 	});
// 	$sourceLabel2.on('dragenter dragover', function(evt) {
// 		$sourceLabel2.addClass('onLabel');
// 	});
// 	$treeLabel1.on('dragenter dragover', function(evt) {
// 		$treeLabel1.addClass('onLabel');
// 	});
// 	$treeLabel2.on('dragenter dragover', function(evt) {
// 		$treeLabel2.addClass('onLabel');
// 	});
// 	$pathsLabel.on('dragenter dragover', function(evt) {
// 		$pathsLabel.addClass('onLabel');
// 	});
// 	$scoresLabel.on('dragenter dragover', function(evt) {
// 		$scoresLabel.addClass('onLabel');
// 	});

// 	sourceLabel1.ondrop = function(evt) {
// 	  sourceFile1.files = evt.dataTransfer.files;
// 	  $sourceLabel1.removeClass('onLabel');
// 	};
// 	sourceLabel2.ondrop = function(evt) {
// 	  sourceFile2.files = evt.dataTransfer.files;
// 	  $sourceLabel2.removeClass('onLabel');
// 	};
// 	treeLabel1.ondrop = function(evt) {
// 	  treeFile1.files = evt.dataTransfer.files;
// 	  $treeLabel1.removeClass('onLabel');
// 	};
// 	treeLabel2.ondrop = function(evt) {
// 	  treeFile2.files = evt.dataTransfer.files;
// 	  $treeLabel2.removeClass('onLabel');
// 	};
// 	pathsLabel.ondrop = function(evt) {
// 	  pathsFile.files = evt.dataTransfer.files;
// 	  $pathsLabel.removeClass('onLabel');
// 	};
// 	scoresLabel.ondrop = function(evt) {
// 	  scoresFile.files = evt.dataTransfer.files;
// 	  $scoresLabel.removeClass('onLabel');
// 	};

// 	$sourceLabel1.on('dragleave dragend', function() {
// 	  $sourceLabel1.removeClass('onLabel');
// 	});
// 	$sourceLabel2.on('dragleave dragend', function() {
// 	  $sourceLabel2.removeClass('onLabel');
// 	});
// 	$treeLabel1.on('dragleave dragend', function() {
// 	  $treeLabel1.removeClass('onLabel');
// 	});
// 	$treeLabel2.on('dragleave dragend', function() {
// 	  $treeLabel2.removeClass('onLabel');
// 	});
// 	$pathsLabel.on('dragleave dragend', function() {
// 	  $pathsLabel.removeClass('onLabel');
// 	});
// 	$scoresLabel.on('dragleave dragend', function() {
// 	  $scoresLabel.removeClass('onLabel');
// 	});
// });