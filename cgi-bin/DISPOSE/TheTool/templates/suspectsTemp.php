[%  INCLUDE '../../cgi-bin/DISPOSE/TheTool/templates/header2.html'
	title = 'DISPOSE | Match Results';
%]

	<a href="./login/profile.php">< Profile</a>
	<h1>Your DISPOSE Results</h1>

	<h2>Language: </h2>
	<select id="langSelect">
        <option disabled selected value="none"> -- select an option -- </option>
        <option value="all">[All]</option>
        [%  FOREACH lang IN langs %]
        <option value="[% lang %]">[% lang %]</option>
        [%  END %]
    </select>

    <br><br>

	<table id="resultsTable">
		<thead>
		<tr>
			<th><h2>File 1</h2></th>
			<th><h2>File 2</h2></th>
			<th><h2>Score</h2></th>
		</tr>
		</thead>

		<tbody>
		[%  FOREACH match IN matches %]
		<tr class="[% match.lang %]_result">
			<td>
				<a href="results.php?lang=[% match.lang %]&id=[% match.matchIndex %]&type=match" class="hasTooltip">
					[% match.file1 %]
					<span>[% match.fullName1 %]</span>
				</a>
			</td>
			<td>
				<a href="results.php?lang=[% match.lang %]&id=[% match.matchIndex %]&type=match" class="hasTooltip">
					[% match.file2 %]
					<span>[% match.fullName2 %]</span>
				</a>
			</td>
			<td>[% match.matchNum %]</td>
		</tr>
		[%  END %]
		</tbody>
	</table>

	<script>
		var lang = "<?php echo $_GET['lang'] ?>";

		$().ready(function() {
			$("table#resultsTable").tablesorter( {sortList: [[2,1]]} ); 
			$("select#langSelect").val("none");

			[%  FOREACH lang IN langs %]
			$(".[% lang %]_result").css("display","none");
			[%  END %]

			if (lang) {
				$("select#langSelect").val(lang);
				$("select#langSelect").trigger('change');
			}
		});

		$("select#langSelect").change(function() {

			if (lang.length == 0) {
				window.location.href="results.php?lang="+$("select#langSelect").val();
			}

			if ($("select#langSelect").val() == "all") {
				[%  FOREACH lang IN langs %]
				$(".[% lang %]_result").css("display","none");
				$(".[% lang %]_result").toggle();
				[%  END %]
			}

			[%  FOREACH lang IN langs %]
			if ($("select#langSelect").val() == "[% lang %]") {
				[%  FOREACH lang2 IN langs %]
				$(".[% lang2 %]_result").css("display","none");
				[%  END %]
				$(".[% lang %]_result").toggle();
			}
			[%  END %]

		});
    </script>


[% INCLUDE '../../cgi-bin/DISPOSE/TheTool/templates/footer.html' %]