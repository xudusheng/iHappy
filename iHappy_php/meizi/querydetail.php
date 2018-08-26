<?php
/**
 * Created by PhpStorm.
 * User: Hmily
 * Date: 2018/6/24
 * Time: 上午3:23
 */

require_once '../QueryList/phpQuery.php';
require_once '../QueryList/QueryList.php';
require_once '../jsonresult.php';

use QL\QueryList;

queryPicDetail();

//主函数
function queryPicDetail()
{
    $md5key = trim($_GET['md5key']);

    $connect = mysqli_connect('localhost', 'root', 'xudusheng');
    if (mysqli_errno($connect)) {
        echo mysqli_errno($connect) . '<br/>';
        die();
    }
    mysqli_select_db($connect, 'ihappy');

    $sql = "select * from picture where md5key = '{$md5key}' order by sort asc";
    $queryResult = mysqli_query($connect, $sql);
    $num = $queryResult->num_rows;

    $result = array();
    if ($num > 0) {
        //数据库有值，直接返回结果
        while ($onedata = mysqli_fetch_array($queryResult)) {
            $info = array(
                "ekey" => $onedata['ekey'],
                'md5key' => $onedata['md5key'],
                'title' => $onedata['title'],
                'image_src ' => $onedata['href'],
                'sort' => $onedata['sort'],
            );

            array_push($result, $info);
        }
        echo queryResultToJson($result);

    } else {//未查询到结果
        mysqli_free_result($queryResult);
        //查询video表获取href进行抓包

        $sql = "select * from meizi where md5key = '{$md5key}'";
        $queryResult = mysqli_query($connect, $sql);

        while ($data = mysqli_fetch_array($queryResult)) {
            $href = $data["href"];
            break;
        }
        if (!strlen($href)) {//href异常
            echo queryResultToJson(null);
            die();
        }

//        //开始抓包
        startFetchData($href, $connect);
    }
    mysqli_free_result($queryResult);
    mysqli_close($connect);
    die();
}


//爬取详情
function startFetchData($fetchurl, $connect)
{

    $md5string = md5($fetchurl);

//    $html = file_get_contents($fetchurl);

    $data = QueryList::Query($fetchurl,array(
        'image_src' => array('#picture p img','src'),
        'title' => array('#picture p img','alt')
    ), '', 'UTF-8', 'GB2312')->data;

    $result = array();
        $index = 0;
        foreach ($data as $key => $value) {
            $image_src = $data[$key]['image_src'];
            $title = $data[$key]['title'];
            $md5key = $md5string;
            $ekey = $md5key . "{$index}";

            $info = [
                "md5key" => $md5string,
                "ekey" => $ekey,
                "image_src" => $image_src,
                "title" => $title,
            ];

            array_push($result, $info);


            $sql = "INSERT INTO picture(ekey, md5key, title ,image_src, sort) values (" .
                "\"{$ekey}\", " .
                "\"{$md5key}\", " .
                "\"{$image_src}\", " .
                "\"{$title}\", " .
                "\"{$index}\"" .
                ")";
            $index += 1;
//            $bo = mysqli_query($connect, $sql);

        }
    echo queryResultToJson($result);


return;


//    $data = QueryList::Query($html,array(
//        'p' => array('#picture p','html'),
//    ), '', 'UTF-8', 'GB2312')->getData(function($item){
//        $item['p'] = QueryList::Query($item['p'],array(
//            'image_src' => array('img','src'),
//            'title' => array('img','alt'),
//        ), '', 'UTF-8', 'GB2312')->data;
//        return $item;
//    });

    $result = array();
    foreach ($data as $key => $value) {
        $p = $data[$key]['p'];

        $index = 0;
        foreach ($p as $pkey => $pvalue) {
            $image_src = $p[$key]['image_src'];
            $title = $p[$key]['title'];
            $md5key = $md5string;
            $ekey = $md5key . "{$index}";

            $info = [
                "md5key" => $md5string,
                "ekey" => $ekey,
                "image_src" => $image_src,
                "title" => $title,
            ];

            array_push($result, $info);


            $sql = "INSERT INTO picture(ekey, md5key, title ,image_src, sort) values (" .
                "\"{$ekey}\", " .
                "\"{$md5key}\", " .
                "\"{$image_src}\", " .
                "\"{$title}\", " .
                "\"{$index}\"" .
                ")";
            $index += 1;
            $bo = mysqli_query($connect, $sql);

        }

    }

    echo queryResultToJson($result);
    return;
}

//爬取数据函数
function crawl_data($url, $rule)
{
//    $data = QueryList::Query($url, $rule)->data;
    $data = QueryList::Query($url, $rule, '', 'UTF-8', 'GB2312', true)->data;
    return $data;
}


?>