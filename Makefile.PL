require 5.000;
use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'         => 'Email::Stuff',
	'VERSION_FROM' => 'lib/Email/Stuff.pm',
	'PREREQ_PM'    => {
		# Application dependencies
		'Email::Simple::Creator' => 0,     # Missing from Email::MIME::Creator
		'MIME::Base64'           => 0,     # Missing from Email::MIME::Encodings
		'File::Spec'             => '0.82',
		'Email::MIME'            => '1.6',
		'Email::MIME::Creator'   => '1.2',

		# Test dependencies
		'Test::More'           => '0.47',
	},
	($] >= 5.005) ? (
		'AUTHOR'   => 'Adam Kennedy (cpan@ali.as)',
		'ABSTRACT' => 'Email stuff to things and people and stuff',
	) : (),
);
