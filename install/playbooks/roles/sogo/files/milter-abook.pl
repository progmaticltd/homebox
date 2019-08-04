#!/usr/bin/env perl

use ExtUtils::testlib;

use Sendmail::Milter;
use Socket;
use strict;

#
#  Each of these callbacks is actually called with a first argument
#  that is blessed into the pseudo-package Sendmail::Milter::Context. You can
#  use them like object methods of package Sendmail::Milter::Context.
#
#  $ctx is a blessed reference of package Sendmail::Milter::Context to something
#  yucky, but the Mail Filter API routines are available as object methods
#  (sans the smfi_ prefix) from this
#

sub connect_callback
{
    my $ctx = shift;    # Some people think of this as $self
    my $hostname = shift;
    my $sockaddr_in = shift;
    my ($port, $iaddr);

    print "my_connect:\n";
    print "   + hostname: '$hostname'\n";

    if (defined $sockaddr_in)
    {
        ($port, $iaddr) = sockaddr_in($sockaddr_in);
        print "   + port: '$port'\n";
        print "   + iaddr: '" . inet_ntoa($iaddr) . "'\n";
    }

    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

sub helo_callback
{
    my $ctx = shift;
    my $helohost = shift;

    print "my_helo:\n";
    print "   + helohost: '$helohost'\n";

    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

sub envfrom_callback
{
    my $ctx = shift;
    my @args = @_;
    my $message = "";

    print "my_envfrom:\n";
    print "   + args: '" . join(', ', @args) . "'\n";

    $ctx->setpriv(\$message);

    print "   + private data allocated.\n";
    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

sub envrcpt_callback
{
    my $ctx = shift;
    my @args = @_;

    print "my_envrcpt:\n";
    print "   + args: '" . join(', ', @args) . "'\n";

    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

sub header_callback
{
    my $ctx = shift;
    my $headerf = shift;
    my $headerv = shift;

    print "my_header:\n";
    print "   + field: '$headerf'\n";
    print "   + value: '$headerv'\n";

    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

sub eoh_callback
{
    my $ctx = shift;

    print "my_eoh:\n";
    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

sub body_callback
{
    my $ctx = shift;
    my $body_chunk = shift;
    my $len = shift;
    my $message_ref = $ctx->getpriv();

    # Note: You don't need $len to have a good time.
    # But it's there if you like.

    print "my_body:\n";
    print "   + chunk len: $len\n";

    ${$message_ref} .= $body_chunk;

    $ctx->setpriv($message_ref);

    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

sub eom_callback
{
    my $ctx = shift;
    my $message_ref = $ctx->getpriv();
    my $chunk;

    print "my_eom:\n";
    print "   + adding line to message body...\n";

    # Let's have some fun...
    # Note: This doesn't support messages with MIME data.

    # Pig-Latin, Babelfish, Double dutch, soo many possibilities!
    # But we're boring...

    ${$message_ref} .= "---> Append me to this message body!\r\n";

    if (not $ctx->replacebody(${$message_ref}))
    {
        print "   - write error!\n";
        last;
    }

    $ctx->setpriv(undef);
    print "   + private data cleared.\n";

    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

sub abort_callback
{
    my $ctx = shift;

    print "my_abort:\n";

    $ctx->setpriv(undef);
    print "   + private data cleared.\n";

    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

sub close_callback
{
    my $ctx = shift;

    print "my_close:\n";
    print "   + callback completed.\n";

    return SMFIS_CONTINUE;
}

my %my_callbacks =
(
    'connect' =>    \&connect_callback,
    'helo' =>       \&helo_callback,
    'envfrom' =>    \&envfrom_callback,
    'envrcpt' =>    \&envrcpt_callback,
    'header' =>     \&header_callback,
    'eoh' =>        \&eoh_callback,
    'body' =>       \&body_callback,
    'eom' =>        \&eom_callback,
    'abort' =>      \&abort_callback,
    'close' =>      \&close_callback,
);

BEGIN:
{
    if (scalar(@ARGV) < 2)
    {
        print "Usage: perl $0 <name_of_filter> <path_to_sendmail.cf>\n";
        exit;
    }

    my $conn = Sendmail::Milter::auto_getconn($ARGV[0], $ARGV[1]);

    print "Found connection info for '$ARGV[0]': $conn\n";

    if ($conn =~ /^local:(.+)$/)
    {
        my $unix_socket = $1;

        if (-e $unix_socket)
        {
            print "Attempting to unlink UNIX socket '$conn' ... ";

            if (unlink($unix_socket) == 0)
            {
                print "failed.\n";
                exit;
            }
            print "successful.\n";
        }
    }

    if (not Sendmail::Milter::auto_setconn($ARGV[0], $ARGV[1]))
    {
        print "Failed to detect connection information.\n";
        exit;
    }

    #
    #  The flags parameter is optional. SMFI_CURR_ACTS sets all of the
    #  current version's filtering capabilities.
    #
    #  %Sendmail::Milter::DEFAULT_CALLBACKS is provided for you in getting
    #  up to speed quickly. I highly recommend creating a callback table
    #  of your own with only the callbacks that you need.
    #

    if (not Sendmail::Milter::register($ARGV[0], \%my_callbacks,
        SMFI_CURR_ACTS))
    {
        print "Failed to register callbacks for $ARGV[0].\n";
        exit;
    }

    print "Starting Sendmail::Milter $Sendmail::Milter::VERSION engine.\n";

    if (Sendmail::Milter::main())
    {
        print "Successful exit from the Sendmail::Milter engine.\n";
    }
    else
    {
        print "Unsuccessful exit from the Sendmail::Milter engine.\n";
    }
}
