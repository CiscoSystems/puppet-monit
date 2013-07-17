puppet-monit
====================

Usage :

Because each server needs monit, so put the following in site.pp
and inside the node definition::

    class { 'monit::monit':
        server_types => $server_types,
                        monit_account,
                        monit_passwd,
                        data_volumes => ['XXX', 'YYY', 'ZZZ'],
    }

