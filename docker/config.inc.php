<?php
/** @var array $cfg */

$data = yaml_parse_file("/config.yaml");
$data['blowfish_secret'] = $raw = hex2bin($data['blowfish_secret']);
$cfg = array_merge($cfg, $data);

