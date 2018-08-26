<?php
/**
 * Created by PhpStorm.
 * User: Hmily
 * Date: 2018/6/24
 * Time: 上午3:23
 */

require_once '../QueryList/phpQuery.php';
require_once '../QueryList/QueryList.php';

use QL\QueryList;


//抓包，爬数据

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
    $sql = "INSERT INTO meizi(md5key, name, href, image_src) values ";

    $start = trim($_GET['start']);
    $end = trim($_GET['end']);

    echo "爬虫开始...\n";
    for ($i = $start; $i < $end; $i++) {
        echo "正在爬取第{$i}页\n";
        $url = "http://www.meizitu.com/a/more_{$i}.html";
        echo "url为{$url}<br/>";
        $rule = [
            'href' => ['.con .pic > a', 'href'],
            'image_src' => ['.con .pic > a > img', 'src'],
            'name' => ['.con .pic > a > img', 'alt'],
        ];

        $list_data = crawl_data($url, $rule);
        foreach ($list_data as $key => $value) {
            $detail_href = $list_data[$key]['href'];
            //组合数据库
            $db_data['md5key'] = md5($detail_href);
            $db_data['name'] = $list_data[$key]['name'];
            $db_data['href'] = $detail_href;
            $db_data['image_src'] = $list_data[$key]['image_src'];

            $md5key = $db_data['md5key'];
            $md5key = !strlen($md5key) ? "" : $md5key;

            $name = $db_data['name'];
            $name = !strlen($name) ? "" : $name;

            $href = $db_data['href'];
            $href = !strlen($href) ? "" : $href;

            $image_src = $db_data['image_src'];
            $image_src = !strlen($image_src) ? "" : $image_src;

//if (!strlen($md5key) || !strlen($href) || !strlen($name) || !strlen($image_src)) {
//continue;
//}

            $oneData = "(" .
                "\"{$md5key}\", " .
                "\"{$name}\", " .
                "\"{$href}\", " .
                "\"{$image_src}\"" .
                ")";
            $sql_one = $sql . $oneData;

            // echo $oneData;
            echo $sql_one . "<br/>";
            $result = mysqli_query($connect, $sql_one);
            if ($result) {
                echo '插入数据成功' . '<br/>';
            } else {
                echo "插入数据失败" . '<br/>';
                echo "{$name}" . '<br/>';
                echo mysqli_error($connect) . '<br/>';
            }
            echo '<br/>';

        }
        mysqli_free_result($result);   //查询完记得释放空间
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