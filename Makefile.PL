use inc::Module::Install;

name           ( 'Email-Stuff'                         );
abstract       ( 'A more casual approach to creating and sending Email:: emails' );
author         ( 'Adam Kennedy <cpan@ali.as>'          );
version_from   ( 'lib/Email/Stuff.pm'                  );
license        ( 'perl'                                );
requires       ( 'perl'                   => '5.005'   );
requires       ( 'prefork'                => '0.02'    );
requires       ( 'Clone'                  => '0.13'    );
requires       ( 'Email::MIME'            => '1.6'     );
requires       ( 'Email::MIME::Creator'   => '1.3'     );
requires       ( 'Email::Simple::Headers' => '1.01'    );
requires       ( 'Email::Send'            => '1.42'    );
requires       ( 'File::Type'             => '0.22'    );
requires       ( 'File::Slurp'            => '9999.04' );
build_requires ( 'Test::More'             => '0.47'    );
build_requires ( 'File::Spec'             => '0.82'    );
build_requires ( 'Email::Send::Test'      => '0.02'    );
auto_install   (                                       );

&WriteAll;
