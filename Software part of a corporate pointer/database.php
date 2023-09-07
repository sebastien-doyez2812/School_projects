<?php

    define('HOST', 'localhost');
    define('DB_Name','site_web');
    define('USER','root';
    define('PASS','');

    try{
$db = new PDO("mysql:host=" . HOST . ";dbname=" . DB_Name, USER, PASS);
$db -> setAttrubute(PDO::ATTR_ERRMODE, PDO:: ERRMODE_EXCEPTION);
echo "Connecté > OK!";
    } catch(PDOException $e){
        echo $e;
    }