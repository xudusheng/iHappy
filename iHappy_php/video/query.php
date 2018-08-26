<?php
/**
 * Created by PhpStorm.
 * User: Hmily
 * Date: 2018/6/27
 * Time: 上午11:43
 */


require_once '../QueryList/phpQuery.php';
require_once '../QueryList/QueryList.php';
require_once '../jsonresult.php';

$type = trim($_GET['type']);
$page = trim($_GET['page']);
$pagesize = trim($_GET['size']);
$keyword = trim($_GET['keyword']);
$md5key = trim($_GET['md5key']);

query($type,$md5key,$keyword,$page,$pagesize);

function query($type,$md5key,$keyword,$page,$size) {
    $type = trim($_GET['type']);
    $page = trim($_GET['page']);
    $keyword = trim($_GET['keyword']);

    $md5key = trim($_GET['md5key']);

    //详情查询
    if (strlen($md5key)){
        querydetail($md5key);
        return;
    }

    //关键字搜索
    if (strlen($keyword)) {
        $sql = "select * from video where name like \"" . "%{$keyword}%\"";
        querylist($sql);
        return;
    }

    if ($page < 0) {
        $page = 0;
    }
    if ($size < 1) {
        $size = 18;
    }
    $location = $page*$size;//数据库查询的起始位置
    if ($type) {
        $sql = "select * from video where type = {$type} limit {$location}, {$size}";
        querylist($sql);
        return;
    }
}

//TODO:搜索列表数据
function querylist($sql)
{
    $connect = mysqli_connect('localhost', 'root', 'xudusheng');
    if (mysqli_errno($connect)) {
        echo mysqli_errno($connect) . '<br/>';
        die();
    }
    mysqli_select_db($connect, 'ihappy');

    $queryResult = mysqli_query($connect, $sql);
    $result = array();
    while ($data = mysqli_fetch_array($queryResult)) {
        $info = array(
            "md5key" => $data['md5key'],
            'name' => $data['name'],
            'update_time' => $data['update_time'],
            'image_src' => $data['image_src'],
            'href' => $data['href'],
            'hdtag' => $data['hdtag'],
            'director' => $data['director'],
            'casts' => $data['casts'],
            'style' => $data['style'],
            'nation' => $data['nation'],
            'update_status' => $data['update_status'],
            'score' => $data['score'],
            'summary' => $data['summary'],
        );

        array_push($result, $info);
    }

    echo queryResultToJson($result);

    mysqli_free_result($queryResult);   //查询完记得释放空间
    mysqli_close($connect);
}

?>
