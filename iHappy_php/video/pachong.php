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



//    $type = trim($_GET['type']);
//    $start = trim($_GET['start']);
//    $end = trim($_GET['end']);

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
    $sql = "INSERT INTO video(md5key,type, name,href,update_time, image_src, hdtag, director, casts, style, nation, update_status, score, summary) values ";

    $type = trim($_GET['type']);
    $start = trim($_GET['start']);
    $end = trim($_GET['end']);

    echo "爬虫开始...\n";
    for ($i = $start; $i < $end; $i++) {
        echo "正在爬取第{$i}页\n";
        $url = "http://www.q2002.com/type/{$type}/{$i}.html";
        echo "url为{$url}<br/>";
        $rule = [
            'name' => ['.movie-item .meta > div > a', 'text'],
            'update_time' => ['.movie-item .meta > em > strong > span', 'text'],
            'image_src' => ['.movie-item > a > img', 'src'],
            'href' => ['.movie-item > a', 'href'],
            'hdtag' => ['.movie-item > a > button', 'text'],
        ];

        $list_data = crawl_data($url, $rule);
        foreach ($list_data as $key => $value) {
            $detail_href = 'http://www.q2002.com' . $list_data[$key]['href'];
            //组合数据库
            $db_data['name'] = $list_data[$key]['name'];
            $db_data['href'] = $detail_href;
            $db_data['update_time'] = $list_data[$key]['update_time'];
            $db_data['image_src'] = $list_data[$key]['image_src'];
            $db_data['hdtag'] = $list_data[$key]['hdtag'];
            $db_data['md5key'] = md5($detail_href);


            echo "====={$detail_href}<br/>";
            //爬取详情
            $datail_rule = [
                'title' => ['.table > tbody > tr > td:first-child > span', 'text'],//标题
                'text' => ['.table > tbody > tr > td:last-child', 'text'],//内容
                'summary' => ['.summary', 'text'],//简介
            ];
            $datail_data = crawl_data($detail_href, $datail_rule);
            foreach ($datail_data as $detailkey => $detailvalue) {
                $detail_title = $datail_data[$detailkey]['title'];
                switch ($detail_title) {
                    case '导演':
                        $detail_title = 'director';
                        break;
                    case '主演':
                        $detail_title = 'casts';
                        break;
                    case '类型':
                        $detail_title = 'style';
                        break;
                    case '制片国家':
                        $detail_title = 'nation';
                        break;
                    case '更新状态':
                        $detail_title = 'update_status';
                        break;
                    case '上映日期':
                        $detail_title = 'update_date';
                        break;
                    case '评分':
                        $detail_title = 'score';
                        break;
                    default:
                        break;

                }
                $detail_text = $datail_data[$detailkey]['text'];
                $db_data[$detail_title] = $detail_text;
                $summary = $datail_data[$detailkey]['summary'];
                if (strlen($summary)) {
                    $db_data['summary'] = $summary;
                }
            }
//            print_r($db_data);
            $md5key = $db_data['md5key'];
            $md5key = !strlen($md5key)?" ":$md5key;

            $name = $db_data['name'];
            $name = !strlen($name)?" ":$name;

            $href = $db_data['href'];
            $href = !strlen($href)?" ":$href;
            $update_time = $db_data['update_time'];
            echo $update_time;
            echo '<br/>';
            $update_time = !strlen($update_time)?" ":$update_time;

            $image_src = $db_data['image_src'];
            $image_src = !strlen($image_src)?" ":$image_src;

            $hdtag = $db_data['hdtag'];
            $hdtag = !strlen($hdtag)?" ":$hdtag;

            $director = $db_data['director'];
            $director = !strlen($director)?" ":$director;

            $casts = $db_data['casts'];
            $casts = !strlen($casts)?" ":$casts;

            $style = $db_data['style'];
            $style = !strlen($style)?" ":$style;

            $nation = $db_data['nation'];
            $nation = !strlen($nation)?" ":$nation;

            $update_status = $db_data['update_status'];
            $update_status = !strlen($update_status)?" ":$update_status;

            $score = $db_data['score'];
            $score = !strlen($score)?" ":$score;

            $summary = $db_data['summary'];
            $summary = !strlen($summary)?" ":$summary;



            $oneData = "(" .
                "\"{$md5key}\", " .
                "\"{$type}\", " .
                "\"{$name}\", " .
                "\"{$href}\", " .
                "\"{$update_time}\", " .
                "\"{$image_src}\", " .
                "\"{$hdtag}\", " .
                "\"{$director}\", " .
                "\"{$casts}\", " .
                "\"{$style}\", " .
                "\"{$nation}\", " .
                "\"{$update_status}\", " .
                "\"{$score}\", " .
                "\"{$summary}\"" .
                ")";
            $sql_one = $sql . $oneData;
//            echo $sql_one . '<br/>';

           // echo $oneData;
            echo $sql_one . "<br/>";
            $result = mysqli_query($connect, $sql_one);
            if ($result) {
                echo '插入数据成功' . '<br/>';
            } else {
                echo "插入数据失败" . '<br/>';
                echo "{$name}" . '<br/>';
                echo mysqli_error($connect) . '<br/>';
                //            echo $sql_one . '<br/>';

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