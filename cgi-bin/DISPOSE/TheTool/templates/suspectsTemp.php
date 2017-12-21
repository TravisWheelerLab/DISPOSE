[%  INCLUDE '../../cgi-bin/DISPOSE/TheTool/templates/header2.html'
	title = 'DISPOSE | Match Results';
%]

	<a href="./login/profile.php">< Profile</a>
	<h1>Your DISPOSE Results</h1>

	<h2>Language: </h2>
	<select id="langSelect">
        <option disabled value="none"> -- select an option -- </option>
        <option <?php if($_GET['lang'] == "all"){echo "selected";} ?> value="all">[All]</option>
        [%  FOREACH lang IN langs %]
        <option <?php if($_GET['lang'] == [% lang %]){echo "selected";} ?> value="[% lang %]">[% lang %]</option>
        [%  END %]
    </select>

    <br><br>

	<table id="resultsTable">
		<thead>
		<tr>
			<th><h2>File 1</h2></th>
			<th><h2>Author</h2></th>
			<th><h2>File 2</h2></th>
			<th><h2>Author</h2></th>
			<th><h2>Score</h2></th>
		</tr>
		</thead>

		<tbody>
		[%  FOREACH match IN matches %]
		<tr class="[% match.lang %]_result lang_result">
			<td>
				<a href="results.php?lang=[% match.lang %]&id=[% match.matchIndex %]&type=match" class="hasTooltip">
					[% match.file1 %]
					<span>[% match.fullName1 %]</span>
				</a>

				[% IF match.srcType1 == "1" %]
				<?php
				$fullName1 = "[% match.fullName1 %]";
				preg_match("/\.\/GithubResults\/[^\/]+\/([^\/]+\/[^\/]+)\/[^\/]+\/[^\/]+\/(.+)/", $fullName1, $matches);
				$repoName = $matches[1];
				$directFile = $matches[2];
				echo '[<sub><a href="https://github.com/'.$repoName.'/blob/master/'. $directFile . '"><img src="../img/link.png" class="scaleImg" /></a></sub>]';
				?>
				[% END %]

				[% IF match.srcType1 == "2" %]
				<?php
				echo '[<sub><a href="download.php?source=' . urlencode("[% match.file1 %]") . '&lang=' . urlencode("[% match.lang %]") . 
				'&user=' . urlencode($_SESSION['email']) . '&sourceLoc=' . urlencode("[% match.dirName1 %]") . '"><img src="../img/download.png" class="scaleImg" /></a></sub>]';
				?>
				[% END %]
			</td>
			<td>
				[% match.authName1 %]
			</td>
			<td>
				<a href="results.php?lang=[% match.lang %]&id=[% match.matchIndex %]&type=match" class="hasTooltip">
					[% match.file2 %]
					<span>[% match.fullName2 %]</span>
				</a>
				[% IF match.srcType2 == "1" %]
				<?php
				$fullName2 = "[% match.fullName2 %]";
				preg_match("/\.\/GithubResults\/[^\/]+\/([^\/]+\/[^\/]+)\/[^\/]+\/[^\/]+\/(.+)/", $fullName2, $matches);
				$repoName = $matches[1];
				$directFile = $matches[2];
				echo '[<sub><a href="https://github.com/'.$repoName.'/blob/master/'. $directFile . '"><img src="../img/download.png" class="scaleImg" /></a></sub>]';
				?>
				[% END %]

				[% IF match.srcType2 == "2" %]
				<?php
				echo '[<sub><a href="download.php?source=' . urlencode("[% match.file2 %]") . '&lang=' . urlencode("[% match.lang %]") . 
				'&user=' . urlencode($_SESSION['email']) . '&sourceLoc=' . urlencode("[% match.dirName2 %]") . '"><img src="../img/download.png" class="scaleImg" /></a></sub>]';
				?>
				[% END %]
			</td>
			<td>
				[% match.authName2 %]
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

			if (lang) {
				$("select#langSelect").val(lang);

				if ($("select#langSelect").val() == "all") {
					[%  FOREACH lang IN langs %]
					$(".[% lang %]_result").toggle();
					[%  END %]
				}

				[%  FOREACH lang IN langs %]
				else if ($("select#langSelect").val() == "[% lang %]") {
					$(".[% lang %]_result").toggle();
				}
				[%  END %]

				else {
					window.location.href="results.php";
				}
			}

			$("select#langSelect").trigger('change');

		});

		$("select#langSelect").change(function() {

			if ($("select#langSelect").val().length == 0) {
					window.location.href="results.php";
				}

			if (lang !== $("select#langSelect").val()) {
				window.location.href="results.php?lang="+$("select#langSelect").val();
			}


		});
    </script>


[% INCLUDE '../../cgi-bin/DISPOSE/TheTool/templates/footer.html' %]