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
        $filePath = "/etc/php/8.4/apache/php.ini";
        $content = file_get_contents($filePath);

        $replacePairs = [
            'upload_max_filesize = 2M' => 'upload_max_filesize = ' . getenv('UPLOAD_LIMIT'),
            'post_max_size = 8M' => 'post_max_size = ' . getenv('UPLOAD_LIMIT'),
        ];

        $content = str_replace(
            array_keys($replacePairs),
            array_values($replacePairs),
            $content
        );

        file_put_contents($filePath, $content);
    }

    yaml_emit_file("/config.yaml", $config);
}

main();

