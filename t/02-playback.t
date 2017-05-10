#! /usr/bin/env perl6

use v6.c;
use lib "lib";
use Test;

plan 10;

use MPD::Client;
use MPD::Client::Playback;
use MPD::Client::Status;
use MPD::Client::Exceptions::ArgumentException;

my $conn = mpd-connect(host => "localhost");

subtest "consume" => {
	plan 2;

	mpd-consume(True, $conn);
	is mpd-status("consume", $conn), True, "Consume state is set";

	mpd-consume(False, $conn);
	is mpd-status("consume", $conn), False, "Consume state is not set";
}

subtest "crossfade" => {
	plan 3;

	isa-ok mpd-crossfade($conn), "IO::Socket::INET", "crossfade returns the socket";

	mpd-crossfade(10, $conn);
	is mpd-status("xfade", $conn), 10, "Check wether crossfade is applied properly";

	mpd-crossfade($conn);
	is mpd-status("xfade", $conn), 0, "Check wether crossfade has been removed";
}

subtest "mixrampdb" => {
	plan 4;

	mpd-mixrampdb(-17, $conn);
	is mpd-status("mixrampdb", $conn), -17, "Check wether mixrampdb is applied properly";

	mpd-mixrampdb(-17.7, $conn);
	is-approx mpd-status("mixrampdb", $conn), -17.7, "Check wether mixrampdb is applied properly with a Rat";

	throws-like { mpd-mixrampdb(17, $conn) }, MPD::Client::Exceptions::ArgumentException, "Throws ArgumentException on positive decibel value";

	mpd-mixrampdb($conn);
	is mpd-status("mixrampdb", $conn), 0, "Check wether mixrampdb has been removed";
}

subtest "mixrampdelay" => {
	plan 2;

	mpd-mixrampdelay(5, $conn);
	is mpd-status("mixrampdelay", $conn), 5, "Check wether mixrampdb is applied properly";

	mpd-mixrampdelay($conn);
	is mpd-status("mixrampdelay", $conn), 0, "Check wether mixrampdb has been removed";
}

subtest "random" => {
	plan 3;

	mpd-random(True, $conn);
	is mpd-status("random", $conn), True, "Random state is set";

	mpd-random(False, $conn);
	is mpd-status("random", $conn), False, "Random state is not set";

	mpd-random($conn);
	is mpd-status("random", $conn), True, "Random state has been toggled";
}

subtest "repeat" => {
	plan 3;

	mpd-repeat(True, $conn);
	is mpd-status("repeat", $conn), True, "Repeat state is set";

	mpd-repeat(False, $conn);
	is mpd-status("repeat", $conn), False, "Repeat state is not set";

	mpd-repeat($conn);
	is mpd-status("repeat", $conn), True, "Repeat state has been toggled";
}

subtest "setvol" => {
	plan 5;

	mpd-setvol(0, $conn);
	is mpd-status("volume", $conn), 0, "Set volume to 0";

	mpd-setvol(100, $conn);
	is mpd-status("volume", $conn), 100, "Set volume to 100";

	mpd-setvol(42, $conn);
	is mpd-status("volume", $conn), 42, "Set volume to 42";

	throws-like { mpd-setvol(-1, $conn) }, MPD::Client::Exceptions::ArgumentException, "Throws ArgumentException when negative";
	throws-like { mpd-setvol(101, $conn) }, MPD::Client::Exceptions::ArgumentException, "Throws ArgumentException when above 100";
}

subtest "single" => {
	plan 3;

	mpd-single(True, $conn);
	is mpd-status("single", $conn), True, "Single state is set";

	mpd-single(False, $conn);
	is mpd-status("single", $conn), False, "Single state is not set";

	mpd-single($conn);
	is mpd-status("single", $conn), True, "Single state has been toggled";
}

subtest "replay-gain-mode" => {
	plan 5;

	mpd-replay-gain-mode("off", $conn);
	is mpd-replay-gain-status("replay_gain_mode", $conn), "off", "Replay gain mode is turned off";

	mpd-replay-gain-mode("track", $conn);
	is mpd-replay-gain-status("replay_gain_mode", $conn), "track", "Replay gain mode is set to track";

	mpd-replay-gain-mode("album", $conn);
	is mpd-replay-gain-status("replay_gain_mode", $conn), "album", "Replay gain mode is set to album";

	mpd-replay-gain-mode("auto", $conn);
	is mpd-replay-gain-status("replay_gain_mode", $conn), "auto", "Replay gain mode is set to auto";

	throws-like { mpd-replay-gain-mode("none", $conn); }, MPD::Client::Exceptions::ArgumentException, "Throws ArgumentException when given incorrect mode";
}

subtest "replay-gain-status" => {
	my %response = mpd-replay-gain-status($conn);
	my @keys = [
		"replay_gain_mode",
	];

	plan (@keys.end + 1);

	for @keys -> $key {
		ok %response{$key}:exists, "$key exists";
	}
}
