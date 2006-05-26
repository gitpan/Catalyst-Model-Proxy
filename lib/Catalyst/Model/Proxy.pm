package Catalyst::Model::Proxy;

use strict;
use base 'Catalyst::Model';
use NEXT;

our $VERSION = '0.01';
our $AUTOLOAD;

__PACKAGE__->mk_accessors('target_class');

=head1 NAME

Catalyst::Model::Proxy - Proxy Model Class

=head1 SYNOPSIS

	# a sample use with C<Catalyst::Model::DBI>

	# lib/MyApp/Model/DBI.pm
	package MyApp::Model::DBI;
	
	use base 'Catalyst::Model::DBI';
	
	__PACKAGE__->config(
		dsn           => 'dbi:Pg:dbname=myapp',
		password      => '',
		user          => 'postgres',
		options       => { AutoCommit => 1 },
	);
	
	1;

	# lib/MyApp/Model/Other.pm	
	package MyApp::Model::Other;
	
	use base 'Catalyst::Model::Proxy';
	
	__PACKAGE__->config(
		target_class => 'DBI'
	);
	
	# get access to shared $dbh via proxy mechanism
	sub something {
		my $self = shift;
		my $dbh = $self->dbh;
		# ... do some stuff with $dbh
	}

	# back in the controller

	# lib/MyApp/Controller/Other.pm
	package MyApp::Controller::Other;

	use base 'Catalyst::Controller';	

	my $model = $c->model('Other');
	$model->something;
	
=head1 DESCRIPTION

This is the Catalyst Model Class called C<Catalyst::Model::Proxy> that
implements Proxy Design Pattern. It enables you to make calls to target
classes/subroutines via proxy mechanism. This means reduced memory footprint
because any operations performed on the proxies are forwarded to the 
original complex ( target_class ) object. For more information on the proxy
design pattern refer to: http://en.wikipedia.org/wiki/Proxy_design_pattern

=head1 METHODS

=over 4

=item new

Initializes DBI connection

=cut

sub new {
	my ( $self, $c ) = @_;
	$self = $self->NEXT::new($c);
	$self->{namespace}               ||= ref $self;
	$self->{additional_base_classes} ||= ();
	$self->target_class( $self->{target_class} );
	return $self;
}

sub AUTOLOAD {
	my $self = shift;
	my $sub = $AUTOLOAD;
	$sub =~ s/.*:://;
	my $target_model = $self->{target_model};
	return $target_model->$sub ( @_ ); 
}

sub ACCEPT_CONTEXT {
	my ( $self, $c ) = @_;
	$self->{target_model} = $c->model ( $self->target_class );
	return $self;
}

=item $self->target_class

Returns the current target class for a proxy.

=back

=head1 SEE ALSO

L<Catalyst>

=head1 AUTHOR

Alex Pavlovic, C<alex.pavlovic@taskforce-1.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut

1;
