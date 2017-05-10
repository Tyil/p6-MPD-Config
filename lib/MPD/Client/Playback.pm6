#! /usr/bin/env false

use v6.c;

use MPD::Client::Status;
use MPD::Client::Util;
use MPD::Client::Exceptions::ArgumentException;

unit module MPD::Client::Playback;

multi sub mpd-consume (
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	mpd-consume(!mpd-status("consume", $socket), $socket);
}

multi sub mpd-consume (
	Bool $state,
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	$socket
		==> mpd-send-raw("consume " ~ ($state ?? "1" !! "0"))
		==> mpd-response-ok()
		;

	$socket;
}

multi sub mpd-crossfade (
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	mpd-crossfade(0, $socket);
}

multi sub mpd-crossfade (
	Int $seconds,
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	$socket
		==> mpd-send-raw("crossfade " ~ $seconds)
		==> mpd-response-ok()
		;

	$socket;
}

multi sub mpd-mixrampdb (
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	mpd-mixrampdb(0, $socket);
}

multi sub mpd-mixrampdb (
	Real $decibels,
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	if ($decibels > 0) {
		MPD::Client::Exceptions::ArgumentException.new("Decibel value must be negative").throw;
	}

	$socket
		==> mpd-send-raw("mixrampdb " ~ $decibels)
		==> mpd-response-ok()
		;

	$socket;
}

multi sub mpd-mixrampdelay (
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	mpd-mixrampdelay(0, $socket);
}

multi sub mpd-mixrampdelay (
	Int $seconds,
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	$socket
		==> mpd-send-raw("mixrampdelay " ~ $seconds)
		==> mpd-response-ok()
		;

	$socket;
}

multi sub mpd-random (
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	mpd-random(!mpd-status("random", $socket), $socket);
}

multi sub mpd-random (
	Bool $state,
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	mpd-send-toggleable("random", $state, $socket);
}
