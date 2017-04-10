# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Acl::CloseTicketAfterFAQLinked;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::LinkObject',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Config Acl)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check if child tickets are not closed
    return 1 if !$Param{TicketID} || !$Param{UserID};

    # link tickets
    my $Links = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkList(
        Object => 'Ticket',
        Object2 => 'FAQ',
        Key    => $Param{TicketID},
        State  => 'Valid',
#        Type   => 'ParentChild',
        UserID => $Param{UserID},
    );

    if (!$Links->{FAQ}){

        $Param{Acl}->{"$Param{Config}->{AclName}"} = {
          # match properties
            Properties => {
              # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
            },
          # return possible options (black list)
            PossibleNot => {
              # possible ticket options (black list)
                Ticket => {
                    State => $Param{Config}->{State},
                },
                Action => ['AgentTicketClose'],
            },
        };
        
    }

    return 1;
}

1;
