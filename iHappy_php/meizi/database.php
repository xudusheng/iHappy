<?php
/**
 * Created by PhpStorm.
 * User: Hmily
 * Date: 2018/6/24
 * Time: 下午10:32
 */


sqlstring();



function sqlstring(){

    $meizi = "CREATE TABLE meizi(" .
        "md5key VARCHAR(64) NOT NULL default '', " .
        "name VARCHAR(128) NOT NULL default '', " .
        "href VARCHAR(256) NOT NULL default '', " .
        "image_src VARCHAR(256) NOT NULL default '', " .
        "PRIMARY KEY (md5key))";

    $picture = "CREATE TABLE picture(" .
        "ekey VARCHAR(64) NOT NULL default '', " .//键值 由md5key+index
        "md5key VARCHAR(64) NOT NULL default '', " .//用于查询
        "title VARCHAR(128) NOT NULL default '', " .//按钮标题
        "image_src VARCHAR(256) NOT NULL default '', " .//图片地址
        "sort VARCHAR(64) NOT NULL default '', " .//index，用于排序
        "PRIMARY KEY (ekey))";

    echo $meizi . ';<br/>';
    echo $picture . ';<br/>';

}


?>


