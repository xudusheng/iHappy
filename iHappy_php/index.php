<?php

require_once 'QueryList/phpQuery.php';
require_once 'QueryList/QueryList.php';
use QL\QueryList;

//$html = <<<STR
//<div id="one">
//    <div class="two">
//        <a href="http://querylist.cc">QueryList官网</a>
//        <img src="http://querylist.com/1.jpg" alt="这是图片">
//        <img src="http://querylist.com/2.jpg" alt="这是图片2">
//    </div>
//    <span>其它的<b>一些</b>文本</span>
//</div>
//STR;
//
//
//$rules = array(
//    //采集id为one这个元素里面的纯文本内容
//    'text' => array('#one','text'),
//    //采集class为two下面的超链接的链接
//    'link' => array('.two>a','href'),
//    //采集class为two下面的第二张图片的链接
//    'img' => array('.two>img:eq(1)','src'),
//    //采集span标签中的HTML内容
//    'other' => array('span','html')
//);
//$data = QueryList::Query($html,$rules)->data;
//print_r($data);


//$url = 'http://www.q2002.com';
//
//$ql = QueryList::get($url);
//
//echo $ql->find('title')->text();
/*
$username = trim($_GET['username']);
$password = trim($_GET['password']);
echo "username = " . $username . "<br/>";
echo 'password = ' . $password . "<br/>";

//---连接数据库---
$connect = mysqli_connect('localhost', 'root', 'xudusheng');
if (mysqli_errno($connect)){
    echo mysqli_errno($connect) . '<br/>';
    exit;
}else{
    echo '数据库连接成功' . '<br/>';
}
mysqli_select_db($connect, 'ihappy');

//---增---
//mysqli_set_charset($connect, 'utf8');
//$sql = "INSERT INTO user(username,password) VALUES('" . $username . "' , '" . $password . "')";
//$sql = "INSERT INTO user(username,password) values('黄晓明', 'abcdef'), ('angelababy', 'bcdeef'), ( '陈赫', '123456'),('王宝强', '987654')";
//$result = mysqli_query($connect, $sql);
//if ($result){
//    echo '插入数据成功' . '<br/>';
//}else{
//    echo "插入数据失败" . '<br/>';
//    echo mysqli_error($connect) . '<br/>';
//}

//---删---
//---改---
//---查---
$sql = "select * from user";
$result = mysqli_query($connect, $sql);
while ($data = mysqli_fetch_array($result)){
    echo '用户名：' . $data['username'] . '    密码：' . $data['password'] . "<br/>";
}


mysqli_close($connect);

*/
?>
