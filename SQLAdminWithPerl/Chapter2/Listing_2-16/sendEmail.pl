# This script uses the module Net::SMTP to send SMTP email.
# All the scripts that send email in this book send SMTP email

# To run this script in your own environment, you need to modify the values
# of these variables accordingly:
#  $SMTPServer
#  $recipientRef
#  $sender
#  $sub
#  $to and $from
#  $msg

use strict;
use Net::SMTP;

# Prepare the necessary SMTP email fields
my $SMTPServer = 'mail.linchi.com';
my $recipientRef = [ 'monica@yourTel.com', 'christine@yourTel.com' ];
my $sender = 'victor@linchi.com';
my $sub = 'Hello, world!!';
my ($to, $from) = ('sisters@yourTel.com', 'brothers@linchi.com' );
my $msg = 'This should be in the message body.';

# Send the email using the function dbaSMTPSend, which is wrapper 
# aound the SMTP protocol
dbaSMTPSend($SMTPServer, $recipientRef, $sender, $msg, $sub, $to, $from);


###########################
sub dbaSMTPSend {
    my ($SMTPServer, $recipRef, $sender, $msg, $sub, $to, $from) = @_;

    # Create an SMTP object
    my $smtp = Net::SMTP->new($SMTPServer) or
      die "***Err: couldn't create new Net::SMTP object for $SMTPServer.";

    # Fill up the SMTP fields
    $smtp->mail($sender);
    $smtp->to(@$recipRef);
    $smtp->data();
    $smtp->datasend("Subject: $sub\n"); # $sub is sent in the subject
    $smtp->datasend("To: $to\n");       # will appear in To: header
    $smtp->datasend("From: $from\n");   # will appear in From: header
    $smtp->datasend("\n");
    $smtp->datasend("$msg\n");
    $smtp->datasend() or 
      die "***Err: had problem sending message to the mail server.";
    $smtp->quit or 
      die "***Err: couldn't close the connection to the mail server.";

    return 1;
} # dbaSMTPSend
