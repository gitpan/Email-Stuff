use inc::Module::Install;

name          ( 'Email-Stuff'                     );
abstract      ( 'Email stuff to people and things... and, like, stuff' );
author        ( 'Adam Kennedy<cpan@ali.as>'       );
version_from  ( 'lib/Email/Stuff.pm'              );
license       ( 'perl'                            );

requires      ( 'perl'                 => '5.005' );
requires      ( 'Clone'                => '0.13'  );
requires      ( 'Email::MIME'          => '1.6'   );
requires      ( 'Email::MIME::Creator' => '1.2'   );
requires      ( 'Email::Send'          => '0'     );

build_requires( 'Test::More'           => '0.47'  );
build_requires( 'File::Spec'           => '0.82'  );

auto_install();

&WriteAll;
