
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A more casual approach to creating and sending Email:: emails",
  "AUTHOR" => "Adam Kennedy <alias\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Email-Stuff",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Email::Stuff",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Email::MIME" => "1.901",
    "Email::Send" => "2.185",
    "Email::Simple" => "1.998",
    "File::Basename" => 0,
    "File::Type" => "0.22",
    "Params::Util" => "0.23",
    "prefork" => "1.01"
  },
  "TEST_REQUIRES" => {
    "Email::Send::Test" => "2.04",
    "File::Spec" => "0.80",
    "Test::More" => "0.47"
  },
  "VERSION" => "2.103",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



