package Email::Stuff;

use strict;
use UNIVERSAL 'isa';
use Clone                ();
use Email::MIME          ();
use Email::MIME::Creator ();

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.02';
}





#####################################################################
# Constructor and Accessors

sub new {
	my $class = ref $_[0] || $_[0];
	my $self = bless {
		email => Email::MIME->create(
			header => [],
			parts  => [],
			),
		parts => [],
		}, $class;
	$self;
}

sub headers { @{$_[0]->{email}->{header}} }
sub parts   { grep { defined $_ } @{$_[0]->{parts}} }





#####################################################################
# Header Methods

sub To     { $_[0]->header( 'To'   => $_[1] ) }
sub From   { $_[0]->header( 'From' => $_[1] ) }
sub CC     { $_[0]->header( 'CC'   => $_[1] ) }
sub BCC    { $_[0]->header( 'BCC'  => $_[1] ) }
sub header { $_[0]->{email}->header_set( @_ ) }





#####################################################################
# Body and Attachments

sub text_body {
	my $self       = shift;
	my $body       = defined $_[0] ? shift : return undef;
	my %attributes = (
		# Defaults
		content_type => 'text/plain',
		charset      => 'US-ASCII',
		disposition  => 'attachment',
		# Params overwrite them
		@_ );

	# Create the part in the text slot
	$self->{parts}->[0] = Email::MIME->create(
		attributes => \%attributes,
		body       => $body,
		);
}

sub html_body {
	my $self       = shift;
	my $body       = defined $_[0] ? shift : return undef;
	my %attributes = (
		# Defaults
		content_type => 'text/html',
		charset      => 'US-ASCII',
		disposition  => 'attachment',
		# Params overwrite them
		@_ );

	# Create the part in the HTML slot
	$self->{parts}->[1] = Email::MIME->create(
		attributes => \%attributes,
		body       => $body,
		);
}

sub attach {
	my $self       = shift;
	my $body       = defined $_[0] ? shift : return undef;
	my %attributes = (
		# Cheap defaults
		encoding => 'base64',
		# Params overwrite them
		@_ );

	# The more expensive defaults
	### FINISH ME

	# Determine the slot to put it at
	my $slot = scalar @{$self->{parts}};
	$slot = 3 if $slot < 3;

	# Create the part in the attachment slot
	$self->{parts}->[$slot] = Email::MIME->create(
		attributes => \%attributes,
		body       => $body,
		);
}





#####################################################################
# Output Methods

sub Email {
	my $self = shift;
	my $Email = $self->{email};
	$Email->parts_set( $self->parts );
	$Email;
}

sub as_string {
	$_[0]->Email->as_string;
}

1;

__END__

=pod

=head1 NAME

Email::Stuff - Email stuff to people, and things, and stuff...

=head1 DESCRIPTION

B<Note: Uploaded for review only, guarenteed to do nothing but compile.>

B<I REPEAT. MANY KNOWN BUGS. DO NOT USE!!!>

In the spirit of the rest of the Email:: modules, Email::Stuff is a
relatively light package that wraps over Email::MIME::Creator to take one
more layer of details away from the process of building and sending
medium complexity emails from website and other automated processes.

Email::Stuff is generally used to build emails from within a single
function, so it contains no parsing support, and little modification
support. To re-iterate, this is very much a module for those "slap it
together and send it off" situations, but that still has enough grunt
behind the scenes to do things properly.

=head1 METHODS

=head2 new

Creates a new, empty, Email::Stuff object.

=head2 headers

Returns as a list all of the headers currently set for the Email

=head2 parts

Returns as a list all of the Email::MIME parts for the Email

=head2 header $header => $value

Adds a single named header to the email

=head2 To $address

Adds a To header to the email

=head2 From $address

Adds (yes ADDS, just do it once) a From header to the email

=head2 CC $address

Adds a CC header to the email

=head2 BCC $address

Adds a BCC header to the email

=head2 text_body $body [, $header => $value, ... ]

Sets the text body of the email. Unless specified, all the appropriate
headers are set for you. You may overload any as needed. See
L<Email::MIME::Creator|Email::MIME::Creator> for the actual headers to use.

Returns the actual Email::MIME part created as a convenience

=head2 html_body $body [, $header => $value, ... ]

Set the HTML body of the email. Unless specified, all the appropriate
headers are set for you. You may overload any as needed. See
L<Email::MIME::Creator|Email::MIME::Creator> for the actual headers to use.

Returns the actual Email::MIME part created as a convenience

=head2 attach $contents [, $header => $value, ... ]

Adds an attachment to the email. The first argument is the file contents
followed by (as for text_body and html_body) the list of headers to use.
Email::Stuff should TRY to guess the headers right, but you may wish
to provide them anyway to be sure. Encoding is Base64 by default.

Returns the actual Email::MIME part created as a convenience

=head2 Email

Creates and returns the full L<Email::MIME|Email::MIME> object for the email.

=head2 as_string

Returns the string form of the email. Identical to (and uses behind the
scenes) Email::MIME->as_string.

=head1 TO DO

Finish the trickier auto-headers for attachments

Test, test, test

=head1 SUPPORT

All bugs should be filed via the bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Email%3A%3AStuff>

For other issues, contact the author

=head1 AUTHORS

Adam Kennedy (Maintainer), L<http://ali.as/>, cpan@ali.as

=head1 COPYRIGHT

Copyright (c) 2003-2004 Adam Kennedy. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
