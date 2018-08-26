<?php
/**
 * Created by PhpStorm.
 * User: Hmily
 * Date: 2018/6/24
 * Time: 上午3:23
 */



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