package Email::Stuff;

=pod

=head1 NAME

Email::Stuff - Email stuff to people and things... and, like, stuff

=head1 SYNOPSIS

  # Prepare the message
  my $body = <<'AMBUSH_READY';
  Dear Santa
  
  I have killed Bun Bun.
  
  Yes, I know what you are thinking... but it was actually a total accident.
  
  I was in a crowded line at a BayWatch signing, and I tripped, and stood on his head.
  
  Yeah, I know. Oops!
  
  So, I am willing to sell you the body for $1 million dollars.
  
  Be near the pinhole to the Dimension of Pain at midnight.
  
  Alias
  
  AMBUSH_READY
  
  # Create and Send the Email
  Email::Stuff->From     ('cpan@ali.as'                  )
              ->To       ('santa@northpole.org'          )
              ->BCC      ('bunbun@sluggy.com'            )
              ->text_body($body                          )
              ->attach   (file => 'dead_bunbun_faked.gif',
                          name => 'dead_bunbun_proof.gif')
              ->send     ('sendmail'                     );

=head1 DESCRIPTION

B<Note: Uploaded for review only, guarenteed to do nothing but compile.>

B<I REPEAT. MANY KNOWN BUGS. DO NOT USE, ON PAIN OF BUNNIES!!!>

In the spirit of the rest of the Email:: modules, Email::Stuff is a
relatively light package that wraps over
L<Email::MIME::Creator|Email::MIME::Creator> to take one more layer of
details away from the process of building and sending medium complexity
emails from website and other automated processes.

Email::Stuff is generally used to build emails from within a single
function, so it contains no parsing support, and little modification
support. To re-iterate, this is very much a module for those "slap it
together and send it off" situations, but that still has enough grunt
behind the scenes to do things properly.

=head1 METHODS

As you can see from the synopsis, all methods that B<modify> the
Email::Stuff object returns the object, and thus is chainable.

However, please note that non-modifying methods B<do not> return the
Email::Stuff object, and thus B<are not> chainable.

=cut

use strict;
use UNIVERSAL 'isa';
use Clone                ();
use Email::MIME          ();
use Email::MIME::Creator ();
use Email::Send          ();

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.03';
}





#####################################################################
# Constructor and Accessors

=pod

=head2 new

Creates a new, empty, Email::Stuff object.

=cut

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

sub _self {
	my $either = shift;
	ref($either) ? $either : $either->new;
}

=pod

=head2 headers

Returns, as a list, all of the headers currently set for the Email

=cut

sub headers {
	@{shift->{email}->{header}};
}

=pod

=head2 parts

Returns, as a list, the L<Email::MIME|Email::MIME> parts for the Email

=cut

sub parts {
	grep { defined $_ } @{shift->{parts}};
}





#####################################################################
# Header Methods

=pod

=head2 header $header => $value

Adds a single named header to the email. Note I said B<add> not set,
so you can just keep shoving the headers on. But of course, if you
want to use to overwrite a header, your stuffed. Because B<this module
is not for changing emails, just throwing stuff together and sending it.>

=cut

sub header {
	my $self = shift->_self;
	$self->{email}->header_set(shift, shift)
		? $self : undef;
}

=pod

=head2 To $address

Adds a To header to the email

=cut

sub To {
	my $self = shift->_self;
	$self->{email}->header_set(To => shift)
		? $self : undef;
}

=pod

=head2 From $address

Adds (yes ADDS, you only do it once) a From header to the email

=cut

sub From {
	my $self = shift->_self;
	$self->{email}->header_set(From => shift)
		? $self : undef;
}

=pod

=head2 CC $address

Adds a CC header to the email

=cut

sub CC {
	my $self = shift->_self;
	$self->{email}->header_set(CC => shift)
		? shift : undef;
}

=pod

=head2 BCC $address

Adds a BCC header to the email

=cut

sub BCC {
	my $self = shift->_self;
	$self->{email}->header_set(BCC => shift)
		? shift: undef;
}





#####################################################################
# Body and Attachments

=pod

=head2 text_body $body [, $header => $value, ... ]

Sets the text body of the email. Unless specified, all the appropriate
headers are set for you. You may overload any as needed. See
L<Email::MIME::Creator|Email::MIME::Creator> for the actual headers to use.

=cut

sub text_body {
	my $self       = shift->_self;
	my $body       = defined $_[0] ? shift : return undef;
	my %attributes = (
		# Defaults
		content_type => 'text/plain',
		charset      => 'US-ASCII',
		disposition  => 'attachment',
		# Params overwrite them
		@_,
		);

	# Create the part in the text slot
	$self->{parts}->[0] = Email::MIME->create(
		attributes => \%attributes,
		body       => $body,
		);

	$self;
}

=pod

=head2 html_body $body [, $header => $value, ... ]

Set the HTML body of the email. Unless specified, all the appropriate
headers are set for you. You may overload any as needed. See
L<Email::MIME::Creator|Email::MIME::Creator> for the actual headers to use.

=cut

sub html_body {
	my $self       = shift->_self;
	my $body       = defined $_[0] ? shift : return undef;
	my %attributes = (
		# Defaults
		content_type => 'text/html',
		charset      => 'US-ASCII',
		disposition  => 'attachment',
		# Params overwrite them
		@_,
		);

	# Create the part in the HTML slot
	$self->{parts}->[1] = Email::MIME->create(
		attributes => \%attributes,
		body       => $body,
		);

	$self;
}

=pod

=head2 attach $contents [, $header => $value, ... ]

Adds an attachment to the email. The first argument is the file contents
followed by (as for text_body and html_body) the list of headers to use.
Email::Stuff should TRY to guess the headers right, but you may wish
to provide them anyway to be sure. Encoding is Base64 by default.

=cut

sub attach {
	my $self       = shift->_self;
	my $body       = defined $_[0] ? shift : return undef;
	my %attributes = (
		# Cheap defaults
		encoding => 'base64',
		# Params overwrite them
		@_,
		);

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

	$self;
}





#####################################################################
# Output Methods

=pod

=head2 Email

Creates and returns the full L<Email::MIME|Email::MIME> object for the email.

=cut

sub Email {
	my $self = shift;
	$self->{email}->parts_set( $self->parts );
	$self->{email};
}

=pod

=head2 as_string

Returns the string form of the email. Identical to (and uses behind the
scenes) Email::MIME->as_string.

=cut

sub as_string {
	shift->Email->as_string;
}

=pod

=head2 send

Sends the email via L<Email::Send|Email::Send>.

=cut

sub send {
	my $self = shift;
	### This is probably wong
	Email::Send->send( $self->Email );	
}

1;

=pod

=head1 TO DO

- Finish the trickier automated-headers for attachments.

- Write the unit tests

- Check the stuff we are passing to Email::MIME

=head1 SUPPORT

All bugs should be filed via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Email%3A%3AStuff>

For other issues, contact the author

=head1 AUTHORS

Adam Kennedy (Maintainer), L<http://ali.as/>, cpan@ali.as

=head1 COPYRIGHT

Copyright (c) 2004 Adam Kennedy. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
