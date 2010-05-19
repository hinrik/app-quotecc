package App::QuoteCC::Output::Perl;

use perl5i::latest;
use Moose;
use File::Slurp qw/ write_file /;
use Data::Dump 'dump';
use Template;
use Data::Section qw/ -setup /;
use namespace::clean -except => [ qw/ meta merged_section_data section_data / ];

with qw/ App::QuoteCC::Role::Output /;

has template => (
    isa           => 'Str',
    is            => 'ro',
    lazy_build    => 1,
    documentation => "The Template template to emit",
);

sub _build_template {
    my ($self) = @_;
    my $template = $self->section_data( 'program' );
    return $$template;
}

sub output {
    my ($self) = @_;
    my $handle = $self->file_handle;

    # Get output
    my $out  = $self->_process_template;

    # Spew output
    given ($self->file) {
        when ('-') {
            print $out;
        }
        default {
            write_file($_, $out);
        }
    }

    return;
}

sub _process_template {
    my ($self) = @_;
    my $quotes = $self->quotes;
    my $template = $self->template;
    my $out;

    Template->new->process(
        \$template,
        {
            quotes => $quotes,
            size => scalar(@$quotes),
            escape => sub {
                my ($quotes) = @_;
                my $str = dump @$quotes;
                return $str;
            },
        },
        \$out
    );

    return $out;
}

__PACKAGE__->meta->make_immutable;

=encoding utf8

=head1 NAME

App::QuoteCC::Output::C - Emit quotes in Perl format

=head1 AUTHOR

E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason <avar@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason <avar@cpan.org>

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__DATA__
__[ program ]__
#!/usr/bin/env perl

our @QUOTES = [% escape(quotes) %];

if (@ARGV && $ARGV[0] eq '--all') {
    print $_, "\n" for @QUOTES;
} else {
    print $QUOTES[rand @QUOTES], "\n";
}