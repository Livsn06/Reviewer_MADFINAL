<?php

    const host = 'localhost';
    const user= 'root';
    const pass = '';
    const dbase = 'students';

    $conn = new mysqli(host, user, pass, dbase) or die('Server error!');

?>