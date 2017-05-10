#! /usr/bin/env false

use v6.c;

use MPD::Client::Exceptions::SocketException;

unit module MPD::Client::Util;

#| Send a raw command to the MPD socket.
sub mpd-send-raw (
	Str $message,
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	$socket.put($message);
	$socket;
}

#| Check wether the latest response on the MPD socket is OK.
sub mpd-response-ok (
	IO::Socket::INET $socket
	--> Bool
) is export {
	($socket.get() eq "OK");
}

#| Turn the latest MPD response into a Hash object.
sub mpd-response-hash (
	IO::Socket::INET $socket
	--> Hash
) is export {
	my %response;

	for $socket.lines() -> $line {
		if $line eq "OK" {
			last;
		}

		if ($line ~~ m/(.+)\:\s+(.*)/) {
			%response{$0} = $1;
		}
	}

	# convert stuff to native perl stuff
	%response
		==> convert-bools()
		==> convert-integers()
		==> default-zeroes()
		==> my %perlified-response
		;

	%perlified-response;
}

#| transform 1/0 bools into Perl Bools
sub convert-bools (%input --> Hash)
{
	my %response = %input;
	my @bools = [
		"consume"
	];

	for @bools -> $bool {
		if (!defined(%response{$bool})) {
			next;
		}

		%response{$bool} = (%response{$bool} eq "1" ?? True !! False);
	}

	%response;
}

sub convert-integers (%input --> Hash)
{
	my %response = %input;
	my @integers = [
		"mixrampdb",
		"mixrampdelay"
	];

	for @integers -> $integer {
		if (!defined(%response{$integer})) {
			next;
		}

		%response{$integer} = %response{$integer}.Int;
	}

	%response;
}

#| set default zero values if missing
sub default-zeroes (%input --> Hash)
{
	my %response = %input;
	my @zeroes = [
		"mixrampd",
		"mixrampdelay"
	];

	for @zeroes -> $zero {
		if (defined(%response{$zero})) {
			next;
		}

		%response{$zero} = 0;
	}

	%response;
}
