
use strict;
use warnings;

use Module::Build 0.35;
use lib 'inc'; use Module::Build::Sqitch;

my %module_build_args = (
  "build_requires" => {
    "Capture::Tiny" => 0,
    "File::Spec" => 0,
    "FindBin" => 0,
    "Module::Build" => "0.35",
    "Test::Deep" => 0,
    "Test::Dir" => 0,
    "Test::Exception" => 0,
    "Test::File" => 0,
    "Test::File::Contents" => "0.05",
    "Test::MockModule" => "0.05",
    "Test::More" => "0.94",
    "Test::NoWarnings" => "0.083"
  },
  "configure_requires" => {
    "Module::Build" => "0.35"
  },
  "dist_abstract" => "Sane database change management",
  "dist_author" => [
    "David E. Wheeler <david\@justatheory.com>"
  ],
  "dist_name" => "App-Sqitch",
  "dist_version" => "0.912",
  "license" => "mit",
  "module_name" => "App::Sqitch",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Config" => 0,
    "Config::GitLike" => "1.09",
    "DBI" => 0,
    "DateTime" => 0,
    "Digest::SHA1" => 0,
    "Encode" => 0,
    "File::Basename" => 0,
    "File::Copy" => 0,
    "File::HomeDir" => 0,
    "File::Path" => 0,
    "File::Temp" => 0,
    "Getopt::Long" => 0,
    "Hash::Merge" => 0,
    "IO::Pager" => 0,
    "IPC::System::Simple" => 0,
    "List::Util" => 0,
    "Locale::TextDomain" => 0,
    "Moose" => "2.0300",
    "Moose::Meta::Attribute::Native" => 0,
    "Moose::Util::TypeConstraints" => "2.0300",
    "MooseX::Types::Path::Class" => "0.05",
    "POSIX" => 0,
    "Path::Class" => 0,
    "Pod::Find" => 0,
    "Pod::Usage" => 0,
    "Role::HasMessage" => "0.005",
    "Role::Identifiable::HasIdent" => "0.005",
    "Role::Identifiable::HasTags" => "0.005",
    "StackTrace::Auto" => 0,
    "String::Formatter" => 0,
    "Sub::Exporter" => 0,
    "Sub::Exporter::Util" => 0,
    "Sys::Hostname" => 0,
    "Template::Tiny" => "0.11",
    "Term::ANSIColor" => 0,
    "Throwable" => 0,
    "Try::Tiny" => 0,
    "URI" => 0,
    "User::pwent" => 0,
    "Win32::Locale" => 0,
    "constant" => 0,
    "namespace::autoclean" => "0.11",
    "overload" => 0,
    "parent" => 0,
    "perl" => "v5.10.1",
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0
  },
  "script_files" => [
    "bin/sqitch"
  ]
);


my $build = Module::Build::Sqitch->new(%module_build_args);

$build->create_build_script;
