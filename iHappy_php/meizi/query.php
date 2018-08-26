<?php
/**
 * Created by PhpStorm.
 * User: Hmily
 * Date: 2018/6/27
 * Time: 上午11:43
 */

//require_once "querydetail.php";


require_once '../QueryList/phpQuery.php';
require_once '../QueryList/QueryList.php';

use QL\QueryList;

$mpage = trim($_GET['page']);
$msize = trim($_GET['size']);
$mkeyword = trim($_GET['keyword']);

query($mkeyword,$mpage,$msize);

function query($keyword,$page,$size) {

    //关键字搜索
    if (strlen($keyword)) {
        $sql = "select * from meizi where name like \"" . "%{$keyword}%\"";
        querylist($sql);
        return;
    }

    if ($page < 0) {
        $page = 0;
    }
    if ($size < 1) {
        $size = 18;
    }
    $location = $page * $size;//数据库查询的起始位置
    $sql = "select * from meizi limit {$location}, {$size}";
    querylist($sql);
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
        $md5key = $data['md5key'];
        $name = $data['name'];
        $name = str_replace("<b>", "", $name);
        $name = str_replace("</b>", "", $name);

        $image_src = $data['image_src'];

        $href = $data['href'];

        $info = array(
            "md5key" => $md5key,
            'name' => $name,
            'image_src' => $image_src,
            'href' => $href,
        );

        array_push($result, $info);
    }

    echo queryResultToJson($result);

    mysqli_free_result($queryResult);   //查询完记得释放空间
    mysqli_close($connect);
}

function queryResultToJson($result, $errorcode = 0)
{
    if ($result == null) {
        $jsonResult = array(
            'error_code' => $errorcode,
            'errormessage' => '系统异常',
            'result' => [],
        );
    } else {
        $jsonResult = array(
            'error_code' => $errorcode,
            'errormessage' => '',
            'result' => $result,
        );
    }
    return json_encode($jsonResult);
}
?>