<?php
add_filter( 'plugins_url', function( $url ) {
	static $path;
	if ( ! isset( $path ) ) {
		$path = realpath( __DIR__ . '/pub-sync' );
	}
	return str_replace( '/plugins' . $path, '/mu-plugins/pub-sync', $url );
});

require_once __DIR__ . '/pub-sync/loader.php';
