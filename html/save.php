<?php

    $user = urldecode($_REQUEST["user"]);
    $fileName = `perl ./../cgi-bin/save.pl $user`;
    $filePath = "../results/" . $user . "/offline/" . $fileName;
    
    // Process download
    if(file_exists($filePath)) {
        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="'. $filePath .'"');
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize($filePath));
        flush(); // Flush system output buffer
        readfile($filePath);
        exit;
    }
?>