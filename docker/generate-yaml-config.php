<?php

// this file is responsible for dynamically producing the necessary yaml config file
// for phpmyadmin to use.

function main()
{
    $serverConfig = [
        'compress' => false,
        'AllowNoPassword' => false,
    ];

    if (getenv('PMA_HOST') !== false)
    {
        $serverConfig['host'] = getenv('PMA_HOST');
    }

    if (getenv('PMA_PORT') !== false)
    {
        $serverConfig['port'] = getenv('PMA_PORT');
    }

    if (getenv('PMA_USER') !== false)
    {
        $serverConfig['user'] = getenv('PMA_USER');
    }

    if (getenv('PMA_PASSWORD') !== false)
    {
        $serverConfig['password'] = getenv('PMA_PASSWORD');
        $serverConfig['auth_type'] = 'config';
    }
    else
    {
        $serverConfig['auth_type'] = 'cookie';
    }

    $config = [
        'blowfish_secret' => bin2hex(random_bytes(32)),
        'Servers' => [
            1 => $serverConfig,
        ],
        'UploadDir' => '',
        'SaveDir' => '',
        'TempDir' => sys_get_temp_dir(),
    ];

    // if PMA_ARBITRARY env var provided at all, then enable.
    if (getenv('PMA_ARBITRARY') !== false)
    {
        $config['AllowArbitraryServer'] = 1;
    }


    // also need to update post_max_size and upload_max_filesize if provided UPLOAD_LIMIT
    if (getenv('UPLOAD_LIMIT') !== false)
    {
        $content = file_get_contents();

        $replacePairs = [
            'upload_max_filesize = 2M' => getenv('UPLOAD_LIMIT'),
            'post_max_size = 8M' => getenv('UPLOAD_LIMIT'),
        ];
    }


    yaml_emit_file("/config.yaml", $config);
}



main();


