package Devel::REPL::Plugin::Clipboard;

# ABSTRACT: #clip output to clipboard

use Devel::REPL::Plugin;
use namespace::autoclean;
use Clipboard;
use Term::ANSIColor 2.01 qw(colorstrip);

=head1 COMMANDS

This module provides the following command to your Devel::REPL shell:

=head2 #clip

The C<#clip> puts the output of the last command on your clipboard.

=cut

sub BEFORE_PLUGIN {
	my $self = shift;
	$self->load_plugin('Turtles');
	return;
}

has last_output => (
	is      => 'rw',
	isa     => 'Str',
	lazy    => 1,
	default => '',
);

around 'format_result' => sub {
	my $orig = shift;
	my $self = shift;

	my @ret;
	if (wantarray) {
		@ret = $self->$orig(@_);
	}
	else {
		$ret[0] = $self->$orig(@_);
	}

	# Remove any color control characters that plugins like
	# Data::Printer may have added
	my $output = colorstrip( join( "\n", @ret // () ) );

	$self->last_output($output);

	return wantarray ? @ret : $ret[0];
};

sub command_clip {
	my ($self) = @_;
	Clipboard->copy( $self->last_output );
	return 'Output copied to clipboard';
}

1;
