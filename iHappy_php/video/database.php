<?php
/**
 * Created by PhpStorm.
 * User: Hmily
 * Date: 2018/6/24
 * Time: 下午10:32
 */


sqlstring();



function sqlstring(){
    //$db_data['name'] = $list_data[$key]['name'];
//$db_data['href'] = $detail_href;
//$db_data['update_time'] = $list_data[$key]['update_time'];
//$db_data['image_src'] = $list_data[$key]['image_src'];
//$db_data['hdtag'] = $list_data[$key]['hdtag'];
//$db_data['md5Key'] = md5($db_data['href']);
//case '导演': $detail_title = 'director'; break;
//                    case '主演': $detail_title = 'casts'; break;
//                    case '类型': $detail_title = 'type'; break;
//                    case '制片国家': $detail_title = 'nation'; break;
//                    case '更新状态': $detail_title = 'update_status'; break;
//                    case '上映日期': $detail_title = 'update_date'; break;
//                    case '评分': $detail_title = 'score'; break;
    $video = "CREATE TABLE video(" .
        "md5key VARCHAR(64) NOT NULL default '', " .
        "type VARCHAR(32) NOT NULL default '1', " .
        "name VARCHAR(128) NOT NULL default '', " .
        "href VARCHAR(256) NOT NULL default '', " .
        "update_time VARCHAR(32) NOT NULL default '', " .
        "image_src VARCHAR(256) NOT NULL default '', " .
        "hdtag VARCHAR(32) NOT NULL default '', " .
        "director VARCHAR(256), " .
        "casts VARCHAR(256), " .
        "style VARCHAR(128), " .
        "nation VARCHAR(64), " .
        "update_status VARCHAR(64), " .
        "score VARCHAR(64), " .
        "summary VARCHAR(2046), " .
        "PRIMARY KEY (md5key))";

    $episode = "CREATE TABLE episode(" .
        "ekey VARCHAR(64) NOT NULL default '', " .//键值 由md5key+section+index
        "md5key VARCHAR(64) NOT NULL default '', " .//用于查询
        "title VARCHAR(128) NOT NULL default '', " .//按钮标题
        "href VARCHAR(256) NOT NULL default '', " .//地址
        "sort VARCHAR(64) NOT NULL default '', " .//index，用于排序
        "section VARCHAR(64) NOT NULL default '1'," .
        "PRIMARY KEY (ekey))";//section标题,可能有备选地址

    echo $video . '<br/>';
    echo $episode . '<br/>';


    $data = Array ( 'name' => '暴走家丁', 'type'=>'1', 'href' => 'http://www.q2002.com/show/43998.html', 'update_time' => "", 'image_src' => 'http://wx4.sinaimg.cn/mw690/80df6fe6gy1fsnxewseebj205006k74o.jpg', 'hdtag' => '12集已完结', 'md5key' => '25d280bb56f8c24afe1b53f59fa1b022', 'director' => '张凯', 'summary' => "年轻有为的“富二代”欧阳华,在现代社会意外死亡, 机缘巧合间,却在一个英俊帅气的二十岁唐朝青年的身体里 复活了。初到唐朝的欧阳华饥寒交迫,被迫卖身到王府当了 一名家丁。欧阳华凭借着丰富的现代化知识和机智的头脑不 断应对着来自各个方面的危机,在王府混的风生水起,王爷 秦猛对欧阳华青睐有加,也赢得了郡主秦兰曦和王爷新纳宠 妃穆晓晓的芳心。 入主长乐坊后,欧阳华运用各式各样现代化的经营理念,将 长安城的贫民区:长乐坊经营成了一个现代化的无敌社区, 日渐成为长安的中心。然而树大招风,朝廷和扶桑的阴谋家 同时盯上了长乐坊这块肥肉。随着欧阳华一步步地在唐朝复 制着他在现代社会的成功,真爱、奇遇、险境和灾难", 'casts' => "陶思源 / 傅杨杨", 'style' => '古装剧 / 喜剧 / 穿越剧 / 网剧', 'nation' => '中国大陆', 'update_status' => '12集已完结', 'update_date' => '2018-06-25', 'score' => '豆瓣：3.0' );
    $sql = <<<SQL
INSERT INTO video(md5Key, name, detail_url, update_time, image_src, hdtag, director, casts, type, nation, update_status, score, summary)
values
("{$data['md5Key']}", "1", "{$data["name"]}", "{$data["href"]}", "{$data["update_time"]}", "{$data["image_src"]}", "{$data["hdtag"]}", "{$data["director"]}", "{$data["casts"]}", "{$data["style"]}", "{$data["nation"]}", "{$data["update_status"]}", "{$data["score"]}", "{$data["summary"]}")

SQL;

    echo "insert sql " . "<br/>" . $sql;
}

?>


