<?php
var_dump($_POST['sql']);
$uploaded = move_uploaded_file( $_FILES['upload']['tmp_name'] , dirname(__FILE__).'/sql/'.$_FILES['upload']['name']);
die();
/*********************
 * V A R I A B L E S *
 *********************/

// example: /full/path/to/file.extension
$old_file = '';
$new_file = '';

// example: http://client.hfwebdev.com
$old_domain = '';
$new_domain = '';




































/*********************
 * T H E   M A G I C *
 *********************/

echo "\n" . 'REPLACING ' . $old_domain . "\n" . 'WITH ' . $new_domain . "\n\n";


echo 'opening source file: ';
$old = file_get_contents($old_file) or $old = false;
if (false === $old) {
	die('FAIL' . "\n\n");
} else {
	echo 'OK' . "\n";
}


echo 'domain character difference: ';
$diff = strlen($old_domain) - strlen($new_domain);
echo $diff . "\n";


echo 'handling serialized links: ';
$count = 0;
$offset = 0;
$old = preg_replace('/s:(\d+:)/', '§∞§∞§$1', $old);
preg_match_all('/§∞§∞§\d+:[^§\n\r]*/', $old, $strings, PREG_OFFSET_CAPTURE);
foreach ($strings[0] as $key => $string) {
	$raw_string_length = preg_replace('/^§∞§∞§(\d+):.*/', '$1', $string[0]);
	$string_length = $raw_string_length + 12 /* weirdo string */ + 4 /* quotes */ + 2 /* colon and semicolon */ + strlen($raw_string_length) /* number of digits in string length */;
	$yanked_string = substr($old, $string[1] - $offset, $string_length);
	$raw_yanked_string = $yanked_string;
	$sub_count = 0;
	while (1 === preg_match('#' . $old_domain . '#', $yanked_string)) {
		$yanked_string = preg_replace('#' . $old_domain . '#', $new_domain, $yanked_string, 1);
		$sub_count++;
	}
	if ($sub_count > 0) {
		$old = substr_replace($old, preg_replace('/§∞§∞§(\d+):/e', '"§∞§∞§" . ("\\1" - ($sub_count * $diff)) . ":"', $yanked_string), $string[1] - $offset, strlen($raw_yanked_string));
		$count += $sub_count;
		$new_string_length = $raw_string_length - ($sub_count * $diff);
		$offset += ($sub_count * $diff) + (strlen($raw_string_length) != strlen($new_string_length) ? strlen($raw_string_length) - strlen($new_string_length) : 0);
	}
}
$old = preg_replace('/§∞§∞§/', 's:', $old);
echo $count . "\n";


echo 'handling all other links: ';
$count = 0;
while (1 === preg_match('#' . $old_domain . '#', $old)) {
	$old = preg_replace('#' . $old_domain . '#', $new_domain, $old, 1);
	$count++;
}
echo $count . "\n";


echo 'opening new file: ';
$new = fopen($new_file, 'w') or $new = false;
if (false === $new) {
	die('FAIL' . "\n\n");
} else {
	echo 'OK' . "\n";
}


echo 'writing new file: ';
if (false === fwrite($new, $old)) {
	die('FAIL' . "\n\n");
} else {
	echo 'OK' . "\n\n";
}

?>
