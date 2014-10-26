package App::Sqitch::Plan::Step;

use v5.10.1;
use utf8;
use namespace::autoclean;
use Moose;
use MooseX::Types::Path::Class;

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has tag => (
    is       => 'ro',
    isa      => 'App::Sqitch::Plan::Tag',
    required => 1,
    weak_ref => 1,
    handles  => [qw(plan)],
);

has _dependencies => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
    lazy     => 1,
    builder  => '_parse_dependencies',
);

has deploy_file => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 1,
    lazy     => 1,
    default  => sub {
        my $self   = shift;
        my $sqitch = $self->plan->sqitch;
        $sqitch->deploy_dir->file( $self->name . '.' . $sqitch->extension );
    }
);

has revert_file => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 1,
    lazy     => 1,
    default  => sub {
        my $self   = shift;
        my $sqitch = $self->plan->sqitch;
        $sqitch->revert_dir->file( $self->name . '.' . $sqitch->extension );
    }
);

has test_file => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 1,
    lazy     => 1,
    default  => sub {
        my $self   = shift;
        my $sqitch = $self->plan->sqitch;
        $sqitch->test_dir->file( $self->name . '.' . $sqitch->extension );
    }
);

sub BUILDARGS {
    my $class = shift;
    my $p = @_ == 1 && ref $_[0] ? { %{ +shift } } : { @_ };
    if ($p->{requires} && $p->{conflicts} ) {
        $p->{_dependencies} = {
            requires  => delete $p->{requires},
            conflicts => delete $p->{conflicts},
        };
    } elsif ($p->{conflicts} || $p->{requires}) {
        require Carp;
        Carp::confess(
            'The "conflicts" and "requires" parameters must both be required',
            ' or omitted'
        );
    }
    return $p;
}

sub deploy_handle {
    my $self = shift;
    $self->plan->open_script($self->deploy_file);
}

sub revert_handle {
    my $self = shift;
    $self->plan->open_script($self->revert_file);
}

sub test_handle {
    my $self = shift;
    $self->plan->open_script($self->test_file);
}

sub requires  { @{ shift->_dependencies->{requires}  } }
sub conflicts { @{ shift->_dependencies->{conflicts} } }

sub _parse_dependencies {
    my $self = shift;
    my $fh   = $self->plan->open_script( $self->deploy_file );

    my $comment = qr{#+|--+|/[*]+|;+};
    my %deps = ( requires => [], conflicts => [] );
    while ( my $line = $fh->getline ) {
        chomp $line;
        last if $line =~ /\A\s*$/;           # Blank line, no more headers.
        last if $line !~ /\A\s*$comment/;    # Must be a comment line.
        my ( $label, $value ) =
            $line =~ /$comment\s*:(requires|conflicts):\s*(.+)/;
        push @{ $deps{$label} ||= [] } => split /\s+/ => $value
            if $label && $value;
    }
    return \%deps;
}

__PACKAGE__->meta->make_immutable;
no Moose;

__END__

=head1 Name

App::Sqitch::Plan::Step - Sqitch deployment plan tag

=head1 Synopsis

  my $plan = App::Sqitch::Plan::Step->new(
      names => \@tag_names,
      steps => \@steps,
  );

=head1 Description

A App::Sqitch::Plan::Step represents a tagged list of deployment steps in a
Sqitch plan. A tag may have one or more names (as multiple tags can represent
a single point in time in the plan), and any number of steps.

=head1 Interface

=head2 Constructors

=head3 C<new>

  my $step = App::Sqitch::Step::Step->new(%params);

Instantiates and returns a App::Sqitch::Step::Step object. The C<requires> and
C<conflicts> attributes must both be present or both be absent.

=head2 Accessors

=head3 C<names>

  my $name = $step->name;

Returns the name of the step.

=head3 C<tag>

  my $tag = $step->tag;

Returns the L<App::Sqitch::Plan::Tag> object with which the step is
associated.

=head3 C<deploy_file>

  my $file = $step->deploy_file;

Returns the path to the deploy script file for the step.

=head3 C<revert_file>

  my $file = $step->revert_file;

Returns the path to the revert script file for the step.

=head3 C<test_file>

  my $file = $step->test_file;

Returns the path to the test script file for the step.

=head2 Instance Methods

=head3 C<names>

  my $steps = $step->steps;

Returns an array reference of deployment steps.

=head3 C<requires>

  my @requires = $step->requires;

Returns a list of the names of steps required by this step.

=head3 C<conflicts>

  my @conflicts = $step->conflicts;

Returns a list of the names of steps with which this step conflicts.

=head3 C<deploy_handle>

  my $fh = $step->deploy_handle;

Returns an L<IO::File> file handle, opened for reading, for the deploy script
for the step.

=head3 C<revert_handle>

  my $fh = $step->revert_handle;

Returns an L<IO::File> file handle, opened for reading, for the revert script
for the step.

=head3 C<test_handle>

  my $fh = $step->test_handle;

Returns an L<IO::File> file handle, opened for reading, for the test script
for the step.

=head1 See Also

=over

=item L<App::Sqitch::Plan>

Class representing a plan.

=item L<sqitch>

The Sqitch command-line client.

=back

=head1 Author

David E. Wheeler <david@justatheory.com>

=head1 License

Copyright (c) 2012 iovation Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut
