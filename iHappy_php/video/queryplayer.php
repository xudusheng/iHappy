<?php
/**
 * Created by PhpStorm.
 * User: Hmily
 * Date: 2018/7/2
 * Time: 下午4:00
 */

require_once '../QueryList/phpQuery.php';
require_once '../QueryList/QueryList.php';

use QL\QueryList;


startwebcrawler();


//主函数
function startwebcrawler()
{
    $ekey = trim($_GET['ekey']);
    $connect = mysqli_connect('localhost', 'root', 'xudusheng');
    if (mysqli_errno($connect)) {
        echo mysqli_errno($connect) . '<br/>';
        die();
    }
    mysqli_select_db($connect, 'ihappy');

    $sql = "select * from episode where ekey = '{$ekey}'";

    $queryResult = mysqli_query($connect, $sql);
    $url = 'http://www.q2002.com';
    while ($onedata = mysqli_fetch_array($queryResult)) {
        $href = $onedata['href'];
        if (strlen($href)) {
            $url = $url . $href;
            break;
        }
    }
    //爬取播放器地址
    $rule = [
        'playerurl' => ['#player > iframe', 'src'],
    ];

    $play_data = QueryList::Query($url, $rule, '', 'UTF-8', 'GB2312')->data;
    $playerurl = '';
    foreach ($play_data as $key => $value) {
        $playerurl = $play_data[$key]['playerurl'];
        if (strlen($playerurl)) {
            break;
        }
    }
//    echo $playerurl . '<br/>';

    //二次爬取播放器地址
    $rule = [
        'playerurl' => ['#player_swf', 'src'],
    ];

    $play_data = QueryList::Query($playerurl, $rule, '', 'UTF-8', 'GB2312')->data;
    foreach ($play_data as $key => $value) {
        $playerurl = $play_data[$key]['playerurl'];
        if (strlen($playerurl)) {
            break;
        }
    }

//    echo $playerurl . '<br/>';

    if (strlen($playerurl)) {
        $jsonResult = array(
            'errorcode' => 0,
            'errormessage' => '系统异常',
            'playerurl' => $playerurl,
        );
    } else {
        $jsonResult = array(
            'errorcode' => -1,
            'errormessage' => '系统异常',
            'playerurl' => '',
        );
    }

    echo json_encode($jsonResult);
}

?>