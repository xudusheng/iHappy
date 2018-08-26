<?php
/**
 * Created by PhpStorm.
 * User: Hmily
 * Date: 2018/6/24
 * Time: 上午3:23
 */

require_once 'QueryList/phpQuery.php';
require_once 'QueryList/QueryList.php';

use QL\QueryList;


startwebcrawler();


//主函数
function startwebcrawler()
{
    //连接数据库，为写入数据做准备
    $connect = mysqli_connect('localhost', 'root', 'xudusheng');
    if (mysqli_errno($connect)) {
        echo mysqli_errno($connect) . '<br/>';
        exit;
    } else {
        echo '数据库连接成功' . '<br/>';
    }
    mysqli_select_db($connect, 'ihappy');

    $sql = 'select * from video';
    $result = mysqli_query($connect, $sql);
//    $type = trim($_GET['type']);
//    $start = trim($_GET['start']);
//    $end = trim($_GET['end']);


    while ($data = mysqli_fetch_array($result)) {
        print_r($data);
        echo '<br/>';
    }

    echo "爬虫结束";
    echo '<br/>';
    mysqli_close($connect);
    die();
}

//爬取数据函数
function crawl_data($url, $rule)
{
//    $data = QueryList::Query($url, $rule)->data;
    $data = QueryList::Query($url, $rule, '', 'UTF-8', 'GB2312')->data;
    return $data;
}


?>