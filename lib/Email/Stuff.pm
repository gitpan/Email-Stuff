package Email::Stuff;

=pod

=head1 NAME

Email::Stuff - A quick and casual approach to creating and sending emails

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
  Email::Stuff->From     ('cpan@ali.as'                      )
              ->To       ('santa@northpole.org'              )
              ->BCC      ('bunbun@sluggy.com'                )
              ->text_body($body                              )
              ->attach   (io('dead_bunbun_faked.gif')->all,
                          filename => 'dead_bunbun_proof.gif')
              ->send;

=head1 DESCRIPTION

B<The basics should all work, but this module is still subject to
name and/or API changes>

Email::Stuff, as its name suggests, is a fairly casual module used
to email "stuff" to people using the most common methods. It is a fairly
high-level module designed for ease of use, but implemented on top of the
tight and correct Email:: modules.

Email::Stuff is typically used to build emails and send them in a single
statement, as seen in the synopsis. And it is certain only for use when
creating and sending emails. As such, it contains no parsing support, and
little modification support. To re-iterate, this is very much a module for
those "slap it together and send it off" situations, but that still has
enough grunt behind the scenes to do things properly.

=head2 Default Mailer

Although it cannot be relied upon to work, the default behaviour is to use
sendmail to send mail, if you don't provide the mail send channel with
either the C<using> method, or as an argument to C<send>.

The use of sendmail as the default mailer is consistent with the behaviour
of the L<Email::Send> module.

=head1 METHODS

As you can see from the synopsis, all methods that B<modify> the
Email::Stuff object returns the object, and thus most normal calls are
chainable.

However, please note that C<send>, and the group of methods that do not
change the Email::Stuff object B<do not> return the  object, and thus
B<are not> chainable.

=cut

use strict;
use Clone                  ();
use File::Basename         ();
use Email::MIME            ();
use Email::MIME::Creator   ();
use Email::Simple::Headers ();
use Email::Send            ();
use prefork 'File::Type';
use prefork 'File::Slurp';

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.07';
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
		send_using => [ 'Sendmail' ],
		parts      => [],
		email      => Email::MIME->create(
			header => [],
			parts  => [],
			),
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
	shift()->{email}->headers;
}

=pod

=head2 parts

Returns, as a list, the L<Email::MIME> parts for the Email

=cut

sub parts {
	grep { defined $_ } @{shift()->{parts}};
}





#####################################################################
# Header Methods

=pod

=head2 header $header => $value

Adds a single named header to the email. Note I said B<add> not set,
so you can just keep shoving the headers on. But of course, if you
want to use to overwrite a header, you're stuffed. Because B<this module
is not for changing emails, just throwing stuff together and sending it.>

=cut

sub header {
	my $self = shift()->_self;
	$self->{email}->header_set(shift, shift) ? $self : undef;
}

=pod

=head2 To $address

Adds a To header to the email

=cut

sub To {
	my $self = shift()->_self;
	$self->{email}->header_set(To => shift) ? $self : undef;
}

=pod

=head2 From $address

Adds (yes ADDS, you only do it once) a From header to the email

=cut

sub From {
	my $self = shift()->_self;
	$self->{email}->header_set(From => shift) ? $self : undef;
}

=pod

=head2 CC $address

Adds a CC header to the email

=cut

sub CC {
	my $self = shift()->_self;
	$self->{email}->header_set(CC => shift) ? $self : undef;
}

=pod

=head2 BCC $address

Adds a BCC header to the email

=cut

sub BCC {
	my $self = shift()->_self;
	$self->{email}->header_set(BCC => shift)
		? $self : undef;
}

=pod

=head2 Subject $text

Adds a subject to the email

=cut

sub Subject {
	my $self = shift()->_self;
	$self->{email}->header_set(Subject => shift) ? $self : undef;
}





#####################################################################
# Body and Attachments

=pod

=head2 text_body $body [, $header => $value, ... ]

Sets the text body of the email. Unless specified, all the appropriate
headers are set for you. You may overload any as needed. See
L<Email::MIME::Creator> for the actual headers to use.

=cut

sub text_body {
	my $self = shift()->_self;
	my $body = defined $_[0] ? shift : return undef;
	my %attr = (
		# Defaults
		content_type => 'text/plain',
		charset      => 'us-ascii',
		format       => 'flowed',
		# Params overwrite them
		@_,
		);

	# Create the part in the text slot
	$self->{parts}->[0] = Email::MIME->create(
		attributes => \%attr,
		body       => $body,
		);

	$self;
}

=pod

=head2 html_body $body [, $header => $value, ... ]

Set the HTML body of the email. Unless specified, all the appropriate
headers are set for you. You may overload any as needed. See
L<Email::MIME::Creator> for the actual headers to use.

=cut

sub html_body {
	my $self = shift()->_self;
	my $body = defined $_[0] ? shift : return undef;
	my %attr = (
		# Defaults
		content_type => 'text/html',
		charset      => 'us-ascii',
		# Params overwrite them
		@_,
		);

	# Create the part in the HTML slot
	$self->{parts}->[1] = Email::MIME->create(
		attributes => \%attr,
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
	my $self = shift()->_self;
	my $body = defined $_[0] ? shift : return undef;
	my %attr = (
		# Cheap defaults
		encoding => 'base64',
		# Params overwrite them
		@_,
		);

	# The more expensive defaults if needed
	unless ( $attr{content_type} ) {
		require File::Type;
		$attr{content_type} = File::Type->checktype_contents($body);
	}

	### MORE?

	# Determine the slot to put it at
	my $slot = scalar @{$self->{parts}};
	$slot = 3 if $slot < 3;

	# Create the part in the attachment slot
	$self->{parts}->[$slot] = Email::MIME->create(
		attributes => \%attr,
		body       => $body,
		);

	$self;
}

=pod

=head2 attach_file $file

Provides a one-argument method to attach a file that already exists
on the filesystem to the email. C<attach_file> will auto-detect the
MIME type, and use the file's current name when attaching.

=cut

sub attach_file {
	my $self = shift;
	my $name = undef;
	my $body = undef;

	# Support IO::All::File arguments
	if ( UNIVERSAL::isa(ref $_[0], 'IO::All::File') ) {
		$name = $_[0]->name;
		$body = $_[0]->all;

	# Support file names
	} elsif ( defined $_[0] and -f $_[0] ) {
		require File::Slurp;
		$name = $_[0];
		$body = File::Slurp::read_file( $_[0] );

	# That's it
	} else {
		return undef;
	}

	# Clean the file name
	$name = File::Basename::basename($name) or return undef;

	# Now attach as normal
	$self->attach( $body, name => $name, filename => $name );
}

=pod

=head2 using $Driver, @options

The C<using> method specifies the L<Email::Send> driver that you want to use to
send the email, and any options that need to be passed to the driver at the
time that we send the mail.

=cut

sub using {
	my $self = shift;
	$self->{send_using} = [ @_ ] if @_;

	# Make sure the driver is initialised
	Email::Send::_init_mailer($self->_driver);

	$self;
}





#####################################################################
# Output Methods

=pod

=head2 email

Creates and returns the full L<Email::MIME> object for the email.

=cut

sub email {
	my $self  = shift;
	my @parts = $self->parts;
	$self->{email}->parts_set( \@parts ) if @parts;
	$self->{email};
}

BEGIN {
	*Email = *email;
}

# Support coercion to an Email::MIME
sub __as_Email_MIME { shift()->email }

=pod

=head2 as_string

Returns the string form of the email. Identical to (and uses behind the
scenes) Email::MIME-E<gt>as_string.

=cut

sub as_string {
	shift()->email->as_string;
}

=pod

=head2 send

Sends the email via L<Email::Send>.

=cut

sub send {
	my $self = shift;
	$self->using(@_) if @_; # Arguments are passed to ->using
	my $email = $self->email or return undef;
	Email::Send::send( $self->_driver, $email, $self->_options );
}

sub _driver {
	my $self = shift;
	$self->{send_using}->[0];	
}

sub _options {
	my $self = shift;
	my $options = $#{$self->{send_using}};
	@{$self->{send_using}}[1 .. $options];
}

1;

=pod

=head1 COOKBOOK

=head2 Custom Alerts

  package SMS::Alert;
  
  sub new {
          shift()->SUPER::new(@_)
                 ->From('monitor@my.website')
                 # Of course, we could have pulled these from
                 # $MyConfig->{support_tech} or something similar.
                 ->To('0416181595@sms.gateway')
                 ->using(SMTP => '123.123.123.123');
  }

  package My::Code;
  
  unless ( $Server->restart ) {
          # Notify the admin on call that a server went down and failed
          # to restart.
          SMS::Alert->Subject("Server $Server failed to restart cleanly")
                    ->send;
  }

=head1 TO DO

- Fix a number of bugs still likely to exist

- Write some proper unit tests. Write ANY unit tests

- Add any additional small bit of automation that arn't too expensive

=head1 SUPPORT

All bugs should be filed via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Email-Stuff>

For other issues, or commercial enhancement or support, contact the author.

=head1 AUTHORS

Adam Kennedy E<lt>cpan@ali.asE<gt>, L<http://ali.as/>

=head1 COPYRIGHT

Copyright (c) 2004 - 2005 Adam Kennedy. All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
