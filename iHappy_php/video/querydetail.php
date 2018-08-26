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

//主函数
function querydetail($md5key)
{

    $connect = mysqli_connect('localhost', 'root', 'xudusheng');
    if (mysqli_errno($connect)) {
        echo mysqli_errno($connect) . '<br/>';
        die();
    }
    mysqli_select_db($connect, 'ihappy');


    $sql = "select * from episode where md5key = '{$md5key}' order by section asc, sort asc";
    $queryResult = mysqli_query($connect, $sql);
    $num = $queryResult->num_rows;

    $result = array();

    $section1 = array();
    $section2 = array();
    $section3 = array();
    if ($num > 0) {
        //数据库有值，直接返回结果
        while ($onedata = mysqli_fetch_array($queryResult)) {
            $section = $onedata['section'];
            $info = array(
                "ekey" => $onedata['ekey'],
                'md5key' => $onedata['md5key'],
                'title' => $onedata['title'],
                'href' => $onedata['href'],
                'sort' => $onedata['sort'],
                'section' => $section,
            );

            if ($section == 1){
                array_push($section1, $info);
            }
            if ($section == 2){
                array_push($section2, $info);
            }
            if ($section == 3){
                array_push($section3, $info);
            }
        }

        if (count($section1)){
            array_push($result, $section1);
        }
        if (count($section2)){
            array_push($result, $section2);
        }
        if (count($section3)){
            array_push($result, $section3);
        }

        echo queryResultToJson($result);
    } else {//未查询到结果
        mysqli_free_result($queryResult);
        //查询video表获取href进行抓包
        $sql = "select * from video where md5key = '{$md5key}'";

        $queryResult = mysqli_query($connect, $sql);

        while ($data = mysqli_fetch_array($queryResult)) {
            $detailHref = $data["href"];
            break;
        }
        if (!strlen($detailHref)) {//href异常
            echo queryResultToJson(null);
            die();
        }
        //开始抓包
        startFetchData($detailHref, $connect);
    }
    mysqli_free_result($queryResult);
    mysqli_close($connect);
    die();
}

function startFetchData($fetchurl, $connect) {
//    $url = 'http://www.q2002.com/show/42531.html';
    $md5string = md5($fetchurl);
    //爬取详情
    $rule = [
        'dslist' => ['.col-md-12 ', 'html'],
    ];

    $data = QueryList::Query($fetchurl, $rule, '', 'UTF-8', 'GB2312')->getData(
        function ($items) {
            $itemsrule = [
                'title' => ['.dslist-group .dslist-group-item > a', 'text'],
                'href' => ['.dslist-group .dslist-group-item > a', 'href']
            ];

            $dslist_html = $items['dslist'];
            $items['dslist'] = QueryList::Query($dslist_html, $itemsrule, '', 'UTF-8', 'GB2312')->

            getData(
                function ($oneItem) {
                    $title = $oneItem['title'];
                    $href = $oneItem['href'];
//                    echo $title . '==' . $href;
//                    echo '<br/>';
                    return $oneItem;
                }
            );

            return $items;
        }
    );

    $result = array();
    for ($i = 0; $i < count($data); $i++) {
        $buttonList = $data[$i]['dslist'];
        $list = array();
        for ($j = 0; $j < count($buttonList); $j++) {

            $button = $buttonList[$j];
            $button['sort'] = "{$j}";
            $button['section'] = "{$i}";
            $button['md5key'] = $md5string . '';
            $button['ekey'] = $md5string . $i . $j;
            $title = $button['title'];
            if (!strlen($title)){
                $jishu = $j + 1;
                $title = '第' .$jishu. '集';
            }
            $button['title'] = $title;
            $sql = "INSERT INTO episode(ekey, md5key, title ,href, sort, section) values (" .
                "\"{$button['ekey']}\", " .
                "\"{$button['md5key']}\", " .
                "\"{$button['title']}\", " .
                "\"{$button['href']}\", " .
                "\"{$button['sort']}\", " .
                "\"{$button['section']}\"" .
                ")";
            array_push($list, $button);
            $bo = mysqli_query($connect, $sql);
        }
     if (count($list)){
         array_push($result, $list);
     }
    }
    echo queryResultToJson($result);
}



?>