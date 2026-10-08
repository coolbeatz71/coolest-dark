#!/usr/bin/env perl

=pod

=head1 NAME

LanguageTour::Perl - Perl language tour

=head1 DESCRIPTION

Covers packages, references, hashes, arrays, regular expressions,
closures, OO with bless, and exception handling.

=cut

use strict;
use warnings;
use feature qw(say signatures);
no warnings 'experimental::signatures';

package LanguageTour::LogEntry;

# Severity levels for a log line.
our %SEVERITY = (debug => 1, info => 2, warning => 3, error => 4);

=head2 new($class, %args)

Creates a new entry.

B<Parameters:> message, severity, tags

B<Returns:> a blessed hashref

=cut

sub new ($class, %args) {
    my $self = {
        message  => $args{message} // die("message required"),
        severity => $args{severity} // 'info',
        tags     => $args{tags} // [],    # inline comment
    };
    return bless $self, $class;
}

sub to_string ($self) {
    return sprintf('[%s] %s (%d tags)', $self->{severity}, $self->{message}, scalar @{ $self->{tags} });
}

package LanguageTour::LogRepository;

sub new ($class) { return bless { store => {} }, $class }

sub find_by_id ($self, $id) {
    return $self->{store}{$id} // undef;
}

sub recent ($self, $take) {
    my @severe = grep { $SEVERITY{ $_->{severity} } >= 3 } values %{ $self->{store} };
    my @messages = map { $_->{message} } @severe;
    return @messages[ 0 .. ( $take - 1 ) ];
}

sub describe ($self, $count, $severity) {
    return 'empty'   if $count == 0;
    return 'failing' if $severity eq 'error';
    return 'busy'    if $count > 100;
    return 'ok';
}

package main;

my $repo  = LanguageTour::LogRepository->new;
my $entry = LanguageTour::LogEntry->new(message => 'hello', severity => 'error');

if ($entry->to_string =~ /^\[(\w+)\]\s+(.*?)\s+\((\d+)\s+tags\)$/) {
    say "severity=$1 message=$2 tags=$3";
}

eval { die "boom\n" };
say "caught: $@" if $@;
