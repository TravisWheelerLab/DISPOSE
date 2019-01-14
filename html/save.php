<?php

    $user = urldecode($_REQUEST["user"]);
    $fileName = `perl ./../cgi-bin/save.pl $user`;
    $filePath = "../results/" . $user . "/offline/" . $fileName;
    
    // Process download
    if(file_exists($filePath)) {
        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="'. $fileName .'"');
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize($filePath));
        
        ob_end_flush(); // Turn off the output buffer
        $fp = fopen($filePath, 'rb');
        fpassthru($fp); // Stream file info
        exit;
    }
?>