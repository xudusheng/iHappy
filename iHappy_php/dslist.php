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
    $type = trim($_GET['type']);
    $start = trim($_GET['start']);
    $end = trim($_GET['end']);

    $url = 'http://www.q2002.com/show/42531.html';
    //爬取详情
    $rule = [
        'dslist' => ['.col-md-12 ', 'html'],
    ];

    $data = QueryList::Query($url, $rule, '', 'UTF-8', 'GB2312')->getData(
        function ($items) {
            $itemsrule = [
                'title' => ['.dslist-group .dslist-group-item > a', 'text'],
                'href' => ['.dslist-group .dslist-group-item > a', 'href']
            ];

            $dslist_html = $items['dslist'];
//            echo $dslist_html;
            $items['dslist'] = QueryList::Query($dslist_html, $itemsrule, '', 'UTF-8', 'GB2312')->

            getData(
                function ($oneItem) {
                    $title = $oneItem['title'];
                    $href = $oneItem['href'];
                    echo $title . '=====' . $href . '<br/>';
                    return $oneItem;
                }
            );

            return $items;
        }
    );

    for ($i = 0; $i < count($data); $i++){
        $buttonList = $data[$i]['dslist'];
        for ($j = 0; $j < count($buttonList); $j++){
            $button = $buttonList[$j];
            $button['sort'] = $j;
            $button['section'] = $i;
            $button['md5key'] = md5($url);
            $button['ekey'] = md5($url) . $i . $j;
            print_r($button);
            echo '<br/>';
        }
        echo '<br/>';
    }

//    print_r(json_encode($data));

    echo "爬虫结束";
    echo '<br/>';
}



?>